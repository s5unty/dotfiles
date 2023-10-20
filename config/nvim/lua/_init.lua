local api = vim.api
local cmd = vim.cmd
local map = vim.keymap.set

-- nvim-cmp: A completion plugin for neovim coded in Lua. {{{1
-- https://github.com/hrsh7th/nvim-cmp
local cmp = require'cmp'
local snippy = require'snippy'
local lspkind = require'lspkind'
-- https://github.com/hrsh7th/nvim-cmp/wiki/Example-mappings#vim-vsnip
local has_words_before = function()
  unpack = unpack or table.unpack
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end
cmp.setup({
  completion = {
    autocomplete = false,
  },
  snippet = {
    expand = function(args)
      snippy.expand_snippet(args.body) -- For `snippy` users.
    end,
  },
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  formatting = {
    format = lspkind.cmp_format(),
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-c>']       = cmp.mapping.abort(),
    ['<C-u>']       = cmp.mapping.scroll_docs(-4),
    ['<C-d>']       = cmp.mapping.scroll_docs(4),
    ['<Space>']     = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Replace,
      select   = true,
    }),
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif snippy.can_expand_or_advance() then
        snippy.expand_or_advance()
      elseif has_words_before() then
        cmp.complete()
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif snippy.can_jump(-1) then
        snippy.previous()
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<CR>"] = cmp.mapping({
       i = function(fallback)
         if cmp.visible() and cmp.get_active_entry() then
           cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
         else
           fallback()
         end
       end,
       s = cmp.mapping.confirm({ select = true }),
       c = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true }),
     }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp', priority = 10, entry_filter = function(entry)
      return require("cmp").lsp.CompletionItemKind.Snippet ~= entry:get_kind()
    end },
    -- XXX priority
    -- https://github.com/saadparwaiz1/cmp_luasnip
    { name = 'snippy', priority = 90 }, -- For snippy users.
  }, {
    { name = 'buffer' },
  })
})

-- Set configuration for specific filetype.
cmp.setup.filetype('gitcommit', {
  sources = cmp.config.sources({
    { name = 'git' }, -- You can specify the `git` source if [you were installed it](https://github.com/petertriho/cmp-git).
  }, {
    { name = 'buffer' },
  })
})

-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({ '/', '?' }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' }
  }
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  })
})


-- cmp_nvim_lsp {{{1
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
local capabilities = require('cmp_nvim_lsp').default_capabilities()
local lspconfig = require('lspconfig')
lspconfig.dartls.setup {
  settings = {
    dart = {
      enableSnippets = false,
    }
  }
}
local servers = { 'dartls', 'gopls', 'pyright' }
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    capabilities = capabilities,
  }
end

-- How can I hide (or ignore specific) hints?
-- https://github.com/hrsh7th/nvim-cmp/issues/685#issuecomment-1002924899
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, {
    signs = {
      severity_limit = "Hint",
    },
    virtual_text = {
      severity_limit = "Warning",
    },
  }
)
map("n", "K",           vim.lsp.buf.hover)
map("n", "<leader>gr",  vim.lsp.buf.rename)
map("n", "<leader>ca",  vim.lsp.buf.code_action)
map("n", "<leader>gd",  vim.lsp.buf.definition)
map("n", "<leader>gi",  vim.lsp.buf.implementation)
map("n", "<leader>gI",  vim.lsp.buf.references)
map("n", "<leader>gds", vim.lsp.buf.document_symbol)
map("n", "<leader>gws", vim.lsp.buf.workspace_symbol)
map("n", "<leader>sh",  vim.lsp.buf.signature_help)
map("n", "<leader>f",   vim.lsp.buf.format)
map("n", "<leader>cl",  vim.lsp.codelens.run)
map("n", "<leader>gl",  vim.diagnostic.setloclist)
map("n", "<leader>ga",  vim.diagnostic.setqflist)
map("n", "<leader>ge",  function() vim.diagnostic.setqflist({ severity = "E" }) end)
map("n", "<leader>gw",  function() vim.diagnostic.setqflist({ severity = "W" }) end)


-- autopairs for neovim written by lua
-- https://github.com/windwp/nvim-autopairs
require("nvim-autopairs").setup { -- {{{1

}


-- Add/change/delete surrounding delimiter pairs with ease. Written with in Lua.
-- https://github.com/kylechui/nvim-surround
require("nvim-surround").setup { -- {{{1

}


-- Vim plugin for automatically highlighting other uses of the word under the...
-- https://github.com/RRethy/vim-illuminate
require('illuminate').configure { -- {{{1
  delay = 600,
}


-- Nvim Treesitter configurations and abstraction layer
-- https://github.com/nvim-treesitter/nvim-treesitter
require('nvim-treesitter.configs').setup { -- {{{1
  ensure_installed = { "bash", "elvish", "go", "groovy", "yaml", "lua", "vim", "vimdoc", "query" },
  highlight = {
    enable = true,
    disable = function(lang, buf)
      if lang == "yaml" then
        return true
      end

      local max_filesize = 1000 * 1024 -- 1MB
      local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
      if ok and stats and stats.size > max_filesize then
        return true
      end
    end,
  },
  refactor = {
    highlight_definitions = {
      enable = true,
      -- Set to false if you have an `updatetime` of ~100.
      clear_on_cursor_move = true,
    },
    smart_rename = {
      enable = true,
      -- Assign keymaps to false to disable them, e.g. `smart_rename = false`.
      keymaps = {
        smart_rename = "<localleader>gr",
      },
    },
  },
}

require'treesitter-context'.setup {
  enable = true,
}

-- Neovim plugin for a code outline window
-- https://github.com/stevearc/aerial.nvim
require("aerial").setup { -- {{{1
  backends = { "lsp", "treesitter", "markdown", "man" },
  layout = {
      resize_to_content = false,
      preserve_equality = true,
  },
  attach_mode = "global",
  -- open_automatic = function(bufnr)
  --   return vim.api.nvim_buf_line_count(bufnr) > 80 -- Enforce a minimum line count
  --     and aerial.num_symbols(bufnr) > 4 -- Enforce a minimum symbol count
  --     and not aerial.was_closed() -- A useful way to keep aerial closed when closed manually
  -- end,

  -- optionally use on_attach to set keymaps when aerial has attached to a buffer
  on_attach = function(bufnr)
    -- Jump forwards/backwards with '{' and '}'
    vim.keymap.set('n', '{', '<cmd>AerialPrev<CR>', {buffer = bufnr})
    vim.keymap.set('n', '}', '<cmd>AerialNext<CR>', {buffer = bufnr})
  end,
}
-- You probably also want to set a keymap to toggle aerial
vim.keymap.set('n', '<leader>z', '<cmd>AerialToggle!<CR>')


-- A Neovim plugin for storing and restoring fcitx status of several mode groups separately.
-- https://github.com/alohaia/fcitx.nvim
require('fcitx') { -- {{{1
    enable = {
        normal   = true,
        insert   = true,
        cmdline  = true,
        cmdtext  = true,
        terminal = true,
        select   = true,
    },
}

-- A blazing fast and easy to configure neovim statusline plugin written in pure lua.
-- https://github.com/nvim-lualine/lualine.nvim
require('lualine').setup { -- {{{1
    options = {
        globalstatus = true,
        icons_enabled = true,
        theme = 'Tomorrow',
        path = 1,
    },
--    tabline = {
--      lualine_a = {
--        {
--          'buffers',
--          icons_enabled = false,
--          component_separators = { left = '', right = ''},
--          section_separators = { left = '', right = ''},
--          mode = 2,
--          use_mode_colors = true,
--        }
--      }
--    }
}
--vim.keymap.set('n', '<M-1>', '<cmd>LualineBuffersJump! 1<CR>')
--vim.keymap.set('n', '<M-2>', '<cmd>LualineBuffersJump! 2<CR>')
--vim.keymap.set('n', '<M-3>', '<cmd>LualineBuffersJump! 3<CR>')
--vim.keymap.set('n', '<M-4>', '<cmd>LualineBuffersJump! $<CR>')
--vim.keymap.set('n', '<M-.>', '<cmd>bn<CR>')
--vim.keymap.set('n', '<M-,>', '<cmd>bp<CR>')

-- A snazzy bufferline for Neovim
-- https://github.com/akinsho/bufferline.nvim
require("bufferline").setup { -- {{{1
    options = {
        always_show_bufferline = false,
        numbers = "ordinal",
        diagnostics = false,
        show_buffer_icons = false,
        show_buffer_close_icons = false,
        show_close_icon = false,
        show_tab_indicators = false,
        show_duplicate_prefix = false, -- whether to show duplicate buffer prefix
        persist_buffer_sort = true, -- whether or not custom sorted buffers should persist
        separator_style = "any",
    },
    highlights = {
      fill = {
        bg = 'none',
      },
      separator = {
        bg = 'none',
      },
      -- same as lualine(Tomorrow)
      background = {
        bg = '#c8c8c8',
      },
      numbers = {
        bg = '#c8c8c8',
      },
      modified = {
        bg = '#c8c8c8',
      },
      duplicate = {
        bg = '#c8c8c8',
      },
      buffer_selected = {
        bg = '#b4b4b4',
      },
      numbers_selected = {
        bg = '#b4b4b4',
      },
      modified_selected = {
        bg = '#b4b4b4',
      },
      duplicate_selected = {
        bg = '#b4b4b4',
      },
    }
}
vim.keymap.set('n', 'gb', '<cmd>BufferLinePick<CR>')
vim.keymap.set('n', '<M-1>', '<cmd>BufferLineGoToBuffer 1<CR>')
vim.keymap.set('n', '<M-2>', '<cmd>BufferLineGoToBuffer 2<CR>')
vim.keymap.set('n', '<M-3>', '<cmd>BufferLineGoToBuffer 3<CR>')
vim.keymap.set('n', '<M-4>', '<cmd>BufferLineGoToBuffer -1<CR>')
vim.keymap.set('n', '<M-.>', '<cmd>BufferLineCycleNext<CR>')
vim.keymap.set('n', '<M-,>', '<cmd>BufferLineCyclePrev<CR>')
vim.keymap.set('n', '<M-0>', '<cmd>BufferLineMoveNext<CR>')
vim.keymap.set('n', '<M-9>', '<cmd>BufferLineMovePrev<CR>')


-- Neovim plugin to manage the file system and other tree like structures.
-- https://github.com/nvim-neo-tree/neo-tree.nvim
require("neo-tree").setup { -- {{{1
  sources = {
    "filesystem",
    "buffers",
    "git_status",
    "document_symbols",
  },
  window = {
    mappings = {
      ["<space>"] = {
        nowait = true, -- disable `nowait` if you have existing combos starting with this char that you want to use
      },
    },
  },
}
vim.keymap.set('n', '<leader>t', '<cmd>Neotree toggle<CR>')
vim.keymap.set('n', '<leader>f', '<cmd>Neotree buffers<CR>')
vim.keymap.set('n', '<leader>s', '<cmd>Neotree document_symbols<CR>')



local api = vim.api
local cmd = vim.cmd
local map = vim.keymap.set

-- https://github.com/williamboman/mason.nvim {{{1
-- Easily install and manage LSP servers, DAP servers, linters, and formatters.
require("mason").setup {}


-- https://github.com/hrsh7th/nvim-cmp -- {{{1
-- nvim-cmp: A completion plugin for neovim coded in Lua.
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


-- https://github.com/hrsh7th/nvim-cmp/issues/685#issuecomment-1002924899 -- {{{2
-- How can I hide (or ignore specific) hints?
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


-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md -- {{{1
-- configs for the nvim lsp client
local capabilities = require('cmp_nvim_lsp').default_capabilities()
local lspconfig = require('lspconfig')
lspconfig.ansiblels.setup{
  cmd = {
    "~/.local/share/nvim/mason/bin/ansible-language-server",
    "--stdio"
  }
}
lspconfig.bashls.setup{
  cmd = {
    "~/.local/share/nvim/mason/bin/bash-language-server",
    "start",
  }
}
lspconfig.dartls.setup {
  settings = {
    dart = {
      enableSnippets = false,
    }
  }
}
local servers = {
  'ansiblels',
  'bashls',
  'dartls',
  'gopls',
  'pyright',
}
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    capabilities = capabilities,
  }
end


-- https://github.com/windwp/nvim-autopairs -- {{{1
-- autopairs for neovim written by lua
require("nvim-autopairs").setup {

}


-- https://github.com/kylechui/nvim-surround -- {{{1
-- Add/change/delete surrounding delimiter pairs with ease. Written with in Lua.
require("nvim-surround").setup {

}


-- https://github.com/nvim-treesitter/nvim-treesitter -- {{{1
-- Nvim Treesitter configurations and abstraction layer
require('nvim-treesitter.configs').setup {
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
  -- https://github.com/nvim-treesitter/nvim-treesitter-refactor {{{2
  -- Refactor modules for nvim-treesitter
  refactor = {
    highlight_definitions = {
      enable = true,
      -- Set to false if you have an `updatetime` of ~100.
      clear_on_cursor_move = false,
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
-- https://github.com/nvim-treesitter/nvim-treesitter-context {{{2
-- A Vim plugin that shows the context of the currently visible buffer contents.
require'treesitter-context'.setup {
  enable = true,
}

-- https://github.com/stevearc/aerial.nvim -- {{{1
-- Neovim plugin for a code outline window
require("aerial").setup {
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


-- https://github.com/alohaia/fcitx.nvim -- {{{1
-- A Neovim plugin for storing and restoring fcitx status of several mode groups separately.
require('fcitx') {
    enable = {
        normal   = true,
        insert   = true,
        cmdline  = true,
        cmdtext  = true,
        terminal = true,
        select   = true,
    },
}

-- https://github.com/nvim-lualine/lualine.nvim -- {{{1
-- A blazing fast and easy to configure neovim statusline plugin written in pure lua.
require('lualine').setup {
    options = {
        globalstatus = true,
        icons_enabled = true,
        theme = 'Tomorrow',
        path = 1,
    },
}


-- https://github.com/akinsho/bufferline.nvim -- {{{1
-- A snazzy bufferline for Neovim
require("bufferline").setup {
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
        custom_filter = function(buf_number, buf_numbers)
          -- https://github.com/stevearc/oil.nvim {{{2
          -- Neovim file explorer: edit your filesystem like a buffer
          if vim.bo[buf_number].filetype ~= "oil" then
            return true
          end
        end,
    },
    highlights = {
      fill = {
        bg = 'none',
      },
      separator = {
        bg = 'none',
      },
      background = {
        bg = 'none',
      },
      numbers = {
        bg = 'none',
      },
      modified = {
        bg = 'none',
      },
      duplicate = {
        bg = 'none',
      },
      buffer_selected = {
        bg = 'none',
      },
      numbers_selected = {
        bg = 'none',
      },
      modified_selected = {
        bg = 'none',
      },
      duplicate_selected = {
        bg = 'none',
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


-- https://github.com/Bekaboo/dropbar.nvim -- {{{1
-- A polished, IDE-like, highly-customizable winbar for Neovim
vim.cmd [[hi WinBar guisp=#c8c8c8 gui=none guibg=#c8c8c8]]
vim.cmd [[hi WinBarNC guisp=#c8c8c8 gui=none guibg=#c8c8c8]]
require('dropbar').setup {
  general = {
    update_interval = 100,
  },
  icons = {
    ui = {
      bar = {
        separator = ' ',
        extends = '…',
      },
      menu = {
        separator = ' ',
        indicator = ' ',
      },
    },
  },
}


-- https://github.com/nvim-telescope/telescope.nvim {{{1
-- Find, Filter, Preview, Pick. All lua, all the time.
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
require('telescope').setup {
  extensions = {
    undo = {
      use_delta = false,
      mappings = {
        i, n = {
          ["<cr>"] = require("telescope-undo.actions").yank_additions,
          ["<S-cr>"] = require("telescope-undo.actions").yank_deletions,
          ["<C-cr>"] = require("telescope-undo.actions").restore,
        },
      },
    },
  },
}
require("telescope").load_extension("undo")

-- https://github.com/NeogitOrg/neogit {{{1
-- A Magit clone for Neovim.
local neogit = require('neogit')
neogit.setup {
}


-- https://github.com/stevearc/oil.nvim {{{1
-- Neovim file explorer: edit your filesystem like a buffer
require("oil").setup {
  use_default_keymaps = true,
  keymaps = {
    ["?"]       = "actions.show_help",
    ["Q"]       = "actions.close",
    ["l"]       = "actions.select",
    ["<CR>"]    = "actions.select",
    ["L"]       = "actions.select_vsplit",
    ["S"]       = "actions.select_split",
    ["P"]       = "actions.select_tab",
    ["-"]       = "actions.parent",
    ["h"]       = "actions.parent",
    ["p"]       = "actions.preview",
    ["<C-l>"]   = "actions.refresh",
  },
}
vim.keymap.set("n", "_", "<cmd>Oil<CR>", { desc = "Open parent directory" })


-- https://github.com/lukas-reineke/indent-blankline.nvim {{{1
-- This plugin adds indentation guides to Neovim.
require("ibl").setup {
  scope = {
    enabled = false,
  },
}
-- 隐藏第一条缩进线
local hooks = require "ibl.hooks"
hooks.register(
  hooks.type.WHITESPACE,
  hooks.builtin.hide_first_space_indent_level
)
hooks.register(
  hooks.type.WHITESPACE,
  hooks.builtin.hide_first_tab_indent_level
)

-- https://github.com/ggandor/leap.nvim {{{1
-- establishing a new standard interface for moving around in the visible area in Vim-like modal editors.
require('leap').add_default_mappings()

--
--


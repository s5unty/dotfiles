local api = vim.api
local cmd = vim.cmd
local map = vim.keymap.set

-- nvim-cmp: A completion plugin for neovim coded in Lua. {{{1
-- https://github.com/hrsh7th/nvim-cmp
local cmp = require'cmp'
local snippy = require'snippy'

cmp.setup({
  snippet = {
    -- REQUIRED - you must specify a snippet engine
    expand = function(args)
      require('snippy').expand_snippet(args.body) -- For `snippy` users.
    end,
  },
  window = {
    -- completion = cmp.config.window.bordered(),
    -- documentation = cmp.config.window.bordered(),
  },
  mapping = cmp.mapping.preset.insert({
    ['<CR>']        = cmp.mapping.abort(),
    ['<C-u>']       = cmp.mapping.scroll_docs(-4),
    ['<C-d>']       = cmp.mapping.scroll_docs(4),
    ['<Space>']     = cmp.mapping.confirm({
      -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
      behavior = cmp.ConfirmBehavior.Replace,
      -- 'select = false' to only confirm explicitly selected item
      select   = false,
    }),
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif snippy.can_jump(1) then
        snippy.next()
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


-- Set up lspconfig. {{{1
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


-- autopairs for neovim written by lua {{{1
-- https://github.com/windwp/nvim-autopairs
require("nvim-autopairs").setup {}


-- Add/change/delete surrounding delimiter pairs with ease. Written with in Lua. {{{1
-- https://github.com/kylechui/nvim-surround
require("nvim-surround").setup {}


-- Vim plugin for automatically highlighting other uses of the word under the... {{{1
-- https://github.com/RRethy/vim-illuminate
require('illuminate').configure {
  delay = 600,
}


-- Nvim Treesitter configurations and abstraction layer {{{1
-- https://github.com/nvim-treesitter/nvim-treesitter
require'nvim-treesitter.configs'.setup {
  ensure_installed = { "bash", "elvish", "go", "groovy", "yaml", "lua", "vim", "vimdoc", "query" },
  highlight = {
    enable = true,
    disable = function(lang, buf)
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

-- Neovim plugin for a code outline window {{{1
-- https://github.com/stevearc/aerial.nvim
local aerial = require("aerial")
aerial.setup {
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


-- A Neovim plugin for storing and restoring fcitx status of several mode groups separately. {{{1
-- https://github.com/alohaia/fcitx.nvim
require'fcitx' {
    enable = {
        normal   = true,
        insert   = true,
        cmdline  = true,
        cmdtext  = true,
        terminal = true,
        select   = true,
    },
}


-- Auto-Focusing and Auto-Resizing Splits/Windows for Neovim written in Lua. {{{1
-- https://github.com/nvim-focus/focus.nvim
require("focus").setup {
    enable = enable, -- Enable module
    commands = true, -- Create Focus commands
    autoresize = {
        enable = true, -- Enable or disable auto-resizing of splits
        width = 0, -- Force width for the focused window
        height = 0, -- Force height for the focused window
        minwidth = 0, -- Force minimum width for the unfocused window
        minheight = 0, -- Force minimum height for the unfocused window
        height_quickfix = 10, -- Set the height of quickfix panel
    },
    split = {
        bufnew = false, -- Create blank buffer for new split windows
        tmux = false, -- Create tmux splits instead of neovim splits
    },
    ui = {
        number = false, -- Display line numbers in the focussed window only
        relativenumber = false, -- Display relative line numbers in the focussed window only
        hybridnumber = true, -- Display hybrid line numbers in the focussed window only
        absolutenumber_unfocussed = false, -- Preserve absolute numbers in the unfocussed windows
        cursorline = false, -- Display a cursorline in the focussed window only
        cursorcolumn = false, -- Display cursorcolumn in the focussed window only
        signcolumn = true, -- Display signcolumn in the focussed window only
        winhighlight = false, -- Auto highlighting for focussed/unfocussed windows
    }
}
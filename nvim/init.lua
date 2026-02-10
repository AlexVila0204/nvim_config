-- =========================================================
-- Neovim "pro" single-file config (init.lua)
-- - Plugin manager: lazy.nvim
-- - Search: Telescope + ripgrep
-- - Syntax: Treesitter
-- - LSP: mason.nvim + lspconfig
-- - Autocomplete: nvim-cmp
-- - Formatting: conform.nvim
-- - Git: gitsigns
-- - File browsing: oil.nvim
-- =========================================================

-- Leader
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
-- Basic options
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.wrap = false
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.cursorline = true
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.updatetime = 200
vim.opt.timeoutlen = 400
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8

-- Indentation
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.smartindent = true

-- Searching
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.incsearch = true
vim.opt.hlsearch = false

-- Undo (persistent)
vim.opt.undofile = true

-- Clipboard
vim.opt.clipboard = "unnamedplus"

-- WSL clipboard helper (recommended)
-- If you install win32yank.exe in Windows and place it in PATH, this works great.
-- If you don't have it, Neovim still works; clipboard may be limited depending on your setup.
if vim.fn.has("wsl") == 1 then
  local win32yank = vim.fn.exepath("win32yank.exe")
  if win32yank ~= "" then
    vim.g.clipboard = {
      name = "win32yank-wsl",
      copy = {
        ["+"] = { win32yank, "-i", "--crlf" },
        ["*"] = { win32yank, "-i", "--crlf" },
      },
      paste = {
        ["+"] = { win32yank, "-o", "--lf" },
        ["*"] = { win32yank, "-o", "--lf" },
      },
      cache_enabled = 0,
    }
  end
end

-- Diagnostics UI
vim.diagnostic.config({
  virtual_text = true,
  severity_sort = true,
  float = { border = "rounded" },
})

-- Keymaps (core)
local map = vim.keymap.set
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })
map({ "n", "v" }, "<leader>y", '"+y', { desc = "Yank to system clipboard" })
map("n", "<leader>Y", '"+Y', { desc = "Yank line to system clipboard" })
map({ "n", "v" }, "<leader>p", '"+p', { desc = "Paste from system clipboard" })
map("n", "<leader>w", "<cmd>w<CR>", { desc = "Save" })
map("n", "<leader>q", "<cmd>q<CR>", { desc = "Quit" })


-- Sessions (auto-session)
map("n", "<leader>ss", "<cmd>SessionSave<CR>", { desc = "Session save" })
map("n", "<leader>sl", "<cmd>SessionLoad<CR>", { desc = "Session load" })
map("n", "<leader>sr", "<cmd>SessionRestore<CR>", { desc = "Session restore" })
map("n", "<leader>sd", "<cmd>SessionDelete<CR>", { desc = "Session delete" })

-- Better window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Window left" })
map("n", "<C-j>", "<C-w>j", { desc = "Window down" })
map("n", "<C-k>", "<C-w>k", { desc = "Window up" })
map("n", "<C-l>", "<C-w>l", { desc = "Window right" })

-- Layout helpers
map("n", "<leader>e", function()
  vim.cmd("vsplit | Oil")
  vim.cmd("wincmd H")
end, { desc = "Explorer left" })

map("n", "<leader>t", function()
  vim.cmd("split | terminal")
  vim.cmd("wincmd J")
end, { desc = "Terminal bottom" })
-- Terminal behavior (no listed buffer, no hijack layout)
vim.api.nvim_create_autocmd("TermOpen", {
  callback = function()
    vim.opt_local.buflisted = false
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
  end,
})
-- =========================================================
-- lazy.nvim bootstrap
-- =========================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- =========================================================
-- Plugins
-- =========================================================
require("lazy").setup({
  -- Theme (clean & popular)
  {
    "folke/tokyonight.nvim",
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("tokyonight")
    end,
  },

  -- Which-key (shows keybind hints)
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {},
  },

  -- Statusline
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = { options = { globalstatus = true } },
  },

  -- File explorer (best “directory as buffer” experience)
  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      default_file_explorer = true, -- hace que Oil reemplace netrw
      view_options = { show_hidden = true },
      keymaps = {
        ["<CR>"] = "actions.select_vsplit", -- Enter abre en split derecha
      },
    },
  },
  -- Telescope (fuzzy find)
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = "Telescope",
    keys = {
      { "<leader>ff", function() require("telescope.builtin").find_files({ hidden = true }) end, desc = "Find files" },
      { "<leader>fg", function() require("telescope.builtin").live_grep() end,                   desc = "Live grep" },
      { "<leader>fb", function() require("telescope.builtin").buffers() end,                     desc = "Buffers" },
      { "<leader>fh", function() require("telescope.builtin").help_tags() end,                   desc = "Help" },
    },
  },

  -- Treesitter (syntax + better parsing) — pinned to legacy API
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    lazy = false,
    build = ":TSUpdate",
    opts = {
      highlight = { enable = true },
      indent = { enable = true },
      ensure_installed = {
        "lua", "vim", "vimdoc",
        "json", "yaml", "toml",
        "bash",
        "sql",
        "javascript", "typescript", "tsx",
        "html", "css",
        "php",
        "go",
      },
    },
    config = function(_, opts)
      require("nvim-treesitter").setup(opts)
    end,
  },

  -- Git signs
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
  },

  -- Comment toggling (gcc / gc)
  {
    "numToStr/Comment.nvim",
    event = "VeryLazy",
    opts = {},
  },

  {
    "rmagatti/auto-session",
    opts = {
      auto_session_suppress_dirs = { "~/", "~/Downloads" },
      auto_save_enabled = true,
      auto_restore_enabled = true,
      auto_session_enable_path_sep = true,
      session_lens = {
        load_on_open = true,
      },
    },
    dependencies = { "nvim-telescope/telescope.nvim" },
  },

  -- Surround (ysiw", ds", cs"' ...)
  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    opts = {},
  },

  -- Autopairs
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {},
  },

  -- LSP manager
  {
    "williamboman/mason.nvim",
    opts = {},
  },
  {
    "mason-org/mason-lspconfig.nvim",
    opts = {
      ensure_installed = { "lua_ls", "jsonls", "yamlls", "ts_ls", "gopls", "phpactor" },
      automatic_installation = true,
    },
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
    },
  },
  { "neovim/nvim-lspconfig" },

  -- Completion
  { "hrsh7th/nvim-cmp",         event = "InsertEnter" },
  { "hrsh7th/cmp-nvim-lsp",     event = "InsertEnter" },
  { "hrsh7th/cmp-buffer",       event = "InsertEnter" },
  { "hrsh7th/cmp-path",         event = "InsertEnter" },
  { "L3MON4D3/LuaSnip",         event = "InsertEnter" },
  { "saadparwaiz1/cmp_luasnip", event = "InsertEnter" },

  -- Formatter
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    opts = {
      format_on_save = function()
        return { timeout_ms = 2000, lsp_fallback = true }
      end,
      formatters_by_ft = {
        lua = { "stylua" },
        json = { "prettierd", "prettier" },
        yaml = { "prettierd", "prettier" },
        javascript = { "prettierd", "prettier" },
        typescript = { "prettierd", "prettier" },
        typescriptreact = { "prettierd", "prettier" },
        php = { "php_cs_fixer" }, -- or "pint" for Laravel, if you prefer
        go = { "gofmt" },
        sql = { "sqlfmt" },       -- optional if installed
      },
    },
    keys = {
      { "<leader>F", function() require("conform").format({ lsp_fallback = true }) end, desc = "Format file" },
    },
  },
})

-- =========================================================
-- LSP + Completion setup
-- =========================================================

-- nvim-cmp
local cmp = require("cmp")
local luasnip = require("luasnip")

cmp.setup({
  snippet = {
    expand = function(args) luasnip.lsp_expand(args.body) end,
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }),
  }),
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "luasnip" },
    { name = "path" },
    { name = "buffer" },
  }),
})

-- LSP

-- LSP (Neovim 0.11+): vim.lsp.config + LspAttach
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- Keymaps al adjuntar LSP (forma moderna)
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local function bmap(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf, desc = desc })
    end

    bmap("n", "gd", vim.lsp.buf.definition, "Go to definition")
    bmap("n", "gr", vim.lsp.buf.references, "References")
    bmap("n", "K", vim.lsp.buf.hover, "Hover")
    bmap("n", "<leader>rn", vim.lsp.buf.rename, "Rename")
    bmap("n", "<leader>ca", vim.lsp.buf.code_action, "Code action")
    bmap("n", "[d", vim.diagnostic.goto_prev, "Prev diagnostic")
    bmap("n", "]d", vim.diagnostic.goto_next, "Next diagnostic")
    bmap("n", "<leader>d", vim.diagnostic.open_float, "Diagnostic float")
  end,
})

-- Extiende configs de servidores (nvim-lspconfig provee cmd/filetypes; tú solo override)
vim.lsp.config("lua_ls", {
  capabilities = capabilities,
  settings = {
    Lua = { diagnostics = { globals = { "vim" } } },
  },
})

vim.lsp.config("jsonls", { capabilities = capabilities })
vim.lsp.config("yamlls", { capabilities = capabilities })
vim.lsp.config("ts_ls", { capabilities = capabilities })
vim.lsp.config("gopls", { capabilities = capabilities })
vim.lsp.config("phpactor", { capabilities = capabilities })

-- Importante:
-- mason-lspconfig (por defecto) habilita automáticamente los servers instalados. :contentReference[oaicite:3]{index=3}
-- Si quieres forzarlo manualmente (opcional):
-- vim.lsp.enable({ "lua_ls", "jsonls", "yamlls", "ts_ls", "gopls", "phpactor" })


-- A few quality-of-life commands
vim.api.nvim_create_user_command("ReloadConfig", function()
  for name, _ in pairs(package.loaded) do
    if name:match("^user") then package.loaded[name] = nil end
  end
  dofile(vim.fn.stdpath("config") .. "/init.lua")
  vim.notify("Neovim config reloaded!", vim.log.levels.INFO)
end, {})

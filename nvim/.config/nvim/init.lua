-- Leaders and plugin globals
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Disable built-in plugins that are unused or replaced.
vim.g.loaded_2html_plugin = 1
vim.g.loaded_gzip = 1
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_tarPlugin = 1
vim.g.loaded_tutor_mode_plugin = 1
vim.g.loaded_zipPlugin = 1

-- Disable default mappings so <C-\> stays free for fzf-lua buffers.
vim.g.tmux_navigator_no_mappings = 1

-- Options
vim.o.exrc = true -- Source per-project .nvim.lua files
vim.opt.ignorecase = true -- Use case insensitive search
vim.opt.smartcase = true -- Except when using capital letters
vim.opt.timeout = false
vim.opt.ttimeout = true
vim.opt.ttimeoutlen = 10 -- Quickly time out on keycodes, but never time out on mappings
vim.opt.number = true -- Show line numbers
vim.opt.hidden = true -- Allow switching away from buffer without closing
vim.opt.wildmenu = true -- Better command-line completion
vim.opt.showcmd = true -- Show partial commands in the last line of the screen
vim.opt.hlsearch = true -- Highlight searches
vim.opt.updatetime = 300
vim.opt.backspace = { "indent", "eol", "start" } -- Allow backspacing over autoindent, line breaks and insert start
vim.opt.autoindent = true
vim.opt.startofline = false -- Make j/k respect columns
vim.opt.confirm = true -- Ask before abandoning changed files
vim.opt.visualbell = true -- Use a visual bell instead of beeping
vim.opt.mouse = "a"
vim.opt.cmdheight = 2
vim.opt.swapfile = false
vim.opt.compatible = false
vim.opt.spelllang = "en_us"
vim.opt.spell = true
vim.opt.cursorline = true

if vim.fn.has("termguicolors") == 1 then
  vim.opt.termguicolors = true
end

-- Clipboard
-- Yank to the system clipboard via OSC52 (forwarded by tmux → Ghostty → host).
-- Paste is intentionally not wired through OSC52: tmux intercepts OSC52 reads
-- and returns its own buffer instead of forwarding to the outer terminal.
vim.g.clipboard = {
  name = "OSC 52",
  copy = {
    ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
    ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
  },
  paste = {
    ["+"] = function()
      return vim.split(vim.fn.getreg('"'), "\n")
    end,
    ["*"] = function()
      return vim.split(vim.fn.getreg('"'), "\n")
    end,
  },
}
vim.schedule(function()
  vim.o.clipboard = "unnamedplus"
end)

-- Plugins
local gh = function(repo)
  return "https://github.com/" .. repo .. ".git"
end

vim.pack.add({
  { src = gh("nvim-mini/mini.icons") },
  { src = gh("navarasu/onedark.nvim") },
  { src = gh("nvim-mini/mini.statusline") },
  { src = gh("nvim-mini/mini.cursorword") },
  { src = gh("lukas-reineke/indent-blankline.nvim") },
  { src = gh("nvim-treesitter/nvim-treesitter-context") },
  { src = gh("nvim-tree/nvim-tree.lua") },
  { src = gh("ibhagwan/fzf-lua") },
  { src = gh("lewis6991/gitsigns.nvim") },
  { src = gh("linrongbin16/gitlinker.nvim") },
  { src = gh("mason-org/mason.nvim") },
  { src = gh("mason-org/mason-lspconfig.nvim") },
  { src = gh("WhoIsSethDaniel/mason-tool-installer.nvim") },
  { src = gh("saghen/blink.cmp"), version = vim.version.range("1.*") },
  { src = gh("neovim/nvim-lspconfig") },
  { src = gh("romus204/tree-sitter-manager.nvim"), version = "develop" },
  { src = gh("stevearc/conform.nvim") },
  { src = gh("MeanderingProgrammer/render-markdown.nvim") },
  { src = gh("tpope/vim-sleuth") },
  { src = gh("christoomey/vim-tmux-navigator") },
}, { load = true, confirm = false })

-- Temporary command shims for Neovim versions before :packupdate and
-- :packdel are available as built-in commands.
local function complete_packages(arg_lead)
  return vim
    .iter(vim.pack.get(nil, { info = false }))
    :map(function(pack)
      return pack.spec.name
    end)
    :filter(function(name)
      return name:find(arg_lead, 1, true) ~= nil
    end)
    :totable()
end

if vim.fn.exists(":packupdate") == 0 then
  vim.api.nvim_create_user_command("PackUpdate", function(info)
    local names = #info.fargs > 0 and info.fargs or nil
    vim.pack.update(names, { force = info.bang })
  end, {
    desc = "Update plugins",
    nargs = "*",
    bang = true,
    complete = complete_packages,
  })
end

if vim.fn.exists(":packdel") == 0 then
  vim.api.nvim_create_user_command("PackDelete", function(info)
    vim.pack.del(info.fargs, { force = info.bang })
  end, {
    desc = "Delete plugins",
    nargs = "+",
    bang = true,
    complete = complete_packages,
  })
end

-- Appearance
require("mini.icons").setup()
require("mini.icons").mock_nvim_web_devicons()

require("onedark").setup({ style = "darker" })
vim.cmd.colorscheme("onedark")

local statusline = require("mini.statusline")
statusline.setup({
  use_icons = true,
  content = {
    active = function()
      local mode, mode_hl = statusline.section_mode({ trunc_width = 120 })
      local git = statusline.section_git({ trunc_width = 40 })
      local diff = statusline.section_diff({ trunc_width = 75 })
      local diagnostics = statusline.section_diagnostics({ trunc_width = 75 })
      local lsp = statusline.section_lsp({ trunc_width = 75 })
      local filename = statusline.section_filename({ trunc_width = 140 })
      local location = statusline.section_location({ trunc_width = 75 })
      local search = statusline.section_searchcount({ trunc_width = 75 })

      local filetype = vim.bo.filetype
      if filetype ~= "" then
        local icon = MiniIcons.get("filetype", filetype)
        filetype = icon .. " " .. filetype
      end

      return statusline.combine_groups({
        { hl = mode_hl, strings = { mode } },
        { hl = "MiniStatuslineDevinfo", strings = { git, diff, diagnostics, lsp } },
        "%<",
        { hl = "MiniStatuslineFilename", strings = { filename } },
        "%=",
        { hl = "MiniStatuslineFileinfo", strings = { filetype } },
        { hl = mode_hl, strings = { search, location } },
      })
    end,
  },
})

---@diagnostic disable-next-line: duplicate-set-field
statusline.section_location = function()
  return "%2l:%-2v %P"
end

local function set_filename_hl()
  local palette = require("onedark.palette").darker
  vim.api.nvim_set_hl(0, "MiniStatuslineFilename", { fg = palette.fg, bg = palette.bg1, bold = true })
end
vim.api.nvim_create_autocmd("ColorScheme", { pattern = "*", callback = set_filename_hl })
set_filename_hl()

require("mini.cursorword").setup()
local function set_cursorword_hl()
  local sp = require("onedark.palette").darker.fg
  vim.api.nvim_set_hl(0, "MiniCursorword", { underline = true, sp = sp, bold = true })
  vim.api.nvim_set_hl(0, "MiniCursorwordCurrent", { underline = true, sp = sp, bold = true })
end
vim.api.nvim_create_autocmd("ColorScheme", { pattern = "*", callback = set_cursorword_hl })
set_cursorword_hl()

require("ibl").setup()
require("treesitter-context").setup({ max_lines = 3 })

-- File navigation
require("nvim-tree").setup({
  sort = {
    sorter = "case_sensitive",
  },
  view = {
    width = {
      min = 30,
      max = 70,
      padding = 1,
    },
  },
  renderer = {
    group_empty = true,
  },
  filters = {
    dotfiles = false,
  },
  git = {
    enable = false,
  },
  diagnostics = {
    enable = true,
    show_on_dirs = true,
  },
})
vim.keymap.set("n", "<C-n>", "<cmd>NvimTreeFindFileToggle<cr>")

-- Fuzzy finding
require("fzf-lua").setup({
  winopts = {
    preview = {
      layout = "flex",
      flip_columns = 170,
    },
  },
})

vim.keymap.set("n", "<C-\\>", function()
  require("fzf-lua").buffers()
end)
vim.keymap.set("n", "<C-p>", function()
  require("fzf-lua").global()
end)
vim.keymap.set("n", "<C-g>", function()
  require("fzf-lua").live_grep()
end)
vim.keymap.set("n", "<leader>gs", function()
  require("fzf-lua").git_status()
end, { desc = "Git status files" })
vim.keymap.set("n", "<leader>gd", function()
  require("fzf-lua").git_diff()
end, { desc = "Git diff files" })
vim.keymap.set("n", "<leader>sh", function()
  require("fzf-lua").help_tags()
end, { desc = "Search help tags" })
vim.keymap.set("n", "<leader>sk", function()
  require("fzf-lua").keymaps()
end, { desc = "Search keymaps" })
vim.keymap.set("n", "<leader>rc", function()
  vim.cmd("source $MYVIMRC")
  vim.notify("Config reloaded")
end, { desc = "Reload config" })

vim.keymap.set("i", "<C-x><C-f>", function()
  FzfLua.complete_file({
    winopts = { preview = { hidden = true } },
  })
end, { silent = true, desc = "Fuzzy complete file" })

vim.keymap.set("i", "<C-x><C-g>", function()
  FzfLua.git_commits({
    winopts = { preview = { hidden = true } },
    complete = function(selected, _, line, col)
      local hash = selected[1]:match("[^ ]+")
      local after = #line > col and line:sub(col + 1) or ""
      return line:sub(1, col) .. hash .. after, col + #hash
    end,
    actions = {
      ["enter"] = require("fzf-lua.actions").complete,
    },
  })
end, { silent = true, desc = "Fuzzy insert git commit hash" })

vim.keymap.set("i", "<C-x><C-a>", function()
  FzfLua.complete_file({
    winopts = { preview = { hidden = true } },
    actions = {
      ["enter"] = function(selected, opts)
        if not selected[1] then
          if opts.__CTX and opts.__CTX.mode == "i" then
            vim.cmd([[noautocmd lua vim.api.nvim_feedkeys('i', 'n', true)]])
          end
          return
        end
        local orig_complete = opts.complete
        opts.complete = function(sel, action_opts, line, col)
          local newline, newcol = orig_complete(sel, action_opts, line, col)
          if not newline then
            return
          end
          local match_pat = opts.word_pattern or "[^%s\"']*"
          local before = col > 1 and (line:sub(1, col - 1):reverse():match(match_pat) or ""):reverse() or ""
          local path_start = col - #before - 1
          return newline:sub(1, path_start) .. "@" .. newline:sub(path_start + 1), newcol + 1
        end
        require("fzf-lua.actions").complete(selected, opts)
      end,
    },
  })
end, { silent = true, desc = "Fuzzy complete @file" })

-- Git
require("gitsigns").setup({
  current_line_blame = true,
  current_line_blame_opts = {
    delay = 300,
  },
  on_attach = function(bufnr)
    vim.keymap.set(
      "n",
      "<leader>hd",
      require("gitsigns").preview_hunk_inline,
      { buffer = bufnr, desc = "Preview hunk inline" }
    )
    vim.keymap.set("n", "<leader>hr", require("gitsigns").reset_hunk, { buffer = bufnr, desc = "Reset hunk" })
  end,
})

vim.keymap.set({ "n", "v" }, "<leader>yg", "<cmd>GitLink<cr>", { desc = "Yank git permalink to clipboard" })

-- Completion and language tooling
require("blink.cmp").setup({
  enabled = function()
    local disabled = { markdown = true, gitcommit = true }
    return not disabled[vim.bo.filetype]
  end,
  keymap = { preset = "default" },
  completion = {
    documentation = { auto_show = true },
  },
  sources = {
    default = { "lsp", "path", "buffer" },
  },
  fuzzy = { implementation = "prefer_rust_with_warning" },
})

require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = { "lua_ls", "tsgo" },
})
require("mason-tool-installer").setup({
  ensure_installed = { "stylua" },
})

vim.lsp.config("*", {
  capabilities = require("blink.cmp").get_lsp_capabilities(),
})
vim.lsp.config("ty", {
  root_markers = { "ty.toml", ".git" },
})
vim.lsp.config("lua_ls", {
  root_markers = { ".luarc.json", ".luarc.jsonc", ".stylua.toml", "stylua.toml", ".git" },
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      workspace = {
        library = { vim.env.VIMRUNTIME },
      },
    },
  },
})
vim.lsp.config("tsgo", {
  root_markers = { "tsconfig.json", "jsconfig.json", "package.json", ".git" },
})
vim.lsp.enable("pyright", false)
vim.lsp.enable("ty")
vim.lsp.enable("lua_ls")
vim.lsp.enable("tsgo")

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
  callback = function(event)
    local map = function(keys, func, desc)
      vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
    end
    map("gd", vim.lsp.buf.definition, "Go to definition")
    map("gD", vim.lsp.buf.declaration, "Go to declaration")

    vim.diagnostic.config({
      update_in_insert = false,
      severity_sort = true,
      float = { border = "rounded", source = "if_many" },
      underline = { severity = { min = vim.diagnostic.severity.WARN } },
      virtual_text = true,
      virtual_lines = false,
      jump = {
        on_jump = function(_, bufnr)
          vim.diagnostic.open_float({
            bufnr = bufnr,
            scope = "cursor",
            focus = false,
          })
        end,
      },
    })

    vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })
  end,
})

-- Treesitter
-- The develop branch is required until version 1.1.0 to work around:
-- https://github.com/romus204/tree-sitter-manager.nvim/issues/189
require("tree-sitter-manager").setup({
  auto_install = true,
  noauto_install = {
    "gitcommit",
    "git_rebase",
    "c",
    "lua",
    "markdown",
    "markdown_inline",
    "query",
    "vim",
    "vimdoc",
  },
})

-- Formatting
require("conform").setup({
  notify_on_error = false,
  format_on_save = function(bufnr)
    local filetypes = {
      "lua",
      "python",
      "typescript",
      "typescriptreact",
      "javascript",
      "javascriptreact",
    }
    if vim.tbl_contains(filetypes, vim.bo[bufnr].filetype) then
      return { timeout_ms = 2000 }
    end
  end,
  default_format_opts = {
    lsp_format = "fallback",
  },
  formatters_by_ft = {
    lua = { "stylua" },
    python = { "ruff_organize_imports", "ruff_format" },
    typescript = { "oxfmt" },
    typescriptreact = { "oxfmt" },
    javascript = { "oxfmt" },
    javascriptreact = { "oxfmt" },
  },
  formatters = {
    oxfmt = {
      command = "oxfmt",
      args = { "--write", "$FILENAME" },
      stdin = false,
    },
  },
})
vim.keymap.set("n", "<leader>f", function()
  require("conform").format({ async = true })
end, { desc = "Format buffer" })

-- Markdown
---@module "render-markdown"
---@type render.md.UserConfig
local render_markdown_opts = {
  sign = { enabled = false },
}
require("render-markdown").setup(render_markdown_opts)

-- Navigation and general keymaps
vim.keymap.set("n", "<C-h>", "<cmd>TmuxNavigateLeft<cr>", { silent = true })
vim.keymap.set("n", "<C-j>", "<cmd>TmuxNavigateDown<cr>", { silent = true })
vim.keymap.set("n", "<C-k>", "<cmd>TmuxNavigateUp<cr>", { silent = true })
vim.keymap.set("n", "<C-l>", "<cmd>TmuxNavigateRight<cr>", { silent = true })

vim.keymap.set("n", "<leader>yp", function()
  local path = vim.fn.expand("%:.")
  vim.fn.setreg("+", path)
  vim.notify('Yanked "' .. path .. '"')
end, { desc = "Yank current file path" })

-- Used by setup.sh to ensure startup reached the end of this configuration.
vim.g.dotfiles_config_loaded = true

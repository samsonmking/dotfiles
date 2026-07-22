return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "mason-org/mason.nvim",
      "mason-org/mason-lspconfig.nvim",
      "saghen/blink.cmp",
    },
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = { "lua_ls", "tsgo" },
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
          map("<leader>e", vim.diagnostic.open_float, "Show diagnostics")
        end,
      })
    end,
  },
  { "mason-org/mason.nvim", opts = {} },
  { "mason-org/mason-lspconfig.nvim" },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = {
      ensure_installed = { "stylua" },
    },
  },
  {
    "romus204/tree-sitter-manager.nvim",
    -- develop branch is required until version 1.1.0 to workaround
    -- https://github.com/romus204/tree-sitter-manager.nvim/issues/189
    branch = "develop",
    config = function()
      require("tree-sitter-manager").setup({
        auto_install = true,
        -- Don't auto-install parsers when nvim runs as git's editor (e.g.
        -- `git commit`): git leaks GIT_INDEX_FILE into the parser clone, whose
        -- checkout then fails with "Unable to create .git/index.lock".
        noauto_install = { "gitcommit", "git_rebase" },
      })
    end,
  },
  {
    "stevearc/conform.nvim",
    config = function()
      require("conform").setup({
        notify_on_error = false,
        format_on_save = function(bufnr)
          local fts = {
            "lua",
            "python",
            "typescript",
            "typescriptreact",
            "javascript",
            "javascriptreact",
          }
          if vim.tbl_contains(fts, vim.bo[bufnr].filetype) then
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
    end,
  },
  {
    "saghen/blink.cmp",
    version = "1.*",
    opts = {
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
    },
  },
}

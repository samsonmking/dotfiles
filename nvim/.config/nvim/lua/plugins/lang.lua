return {
  { "neovim/nvim-lspconfig" },
  { "mason-org/mason.nvim", opts = {} },
  {
    "mason-org/mason-lspconfig.nvim",
    opts = {
      ensure_installed = { "ty", "lua_ls", "tsgo" },
    },
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = {
      ensure_installed = { "stylua" },
    },
  },
  {
    "romus204/tree-sitter-manager.nvim",
    config = function()
      require("tree-sitter-manager").setup({
        ensure_installed = { "python", "typescript", "javascript" },
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
            "python",
            "typescript",
            "typescriptreact",
            "javascript",
            "javascriptreact",
          }
          if vim.tbl_contains(fts, vim.bo[bufnr].filetype) then
            return { timeout_ms = 500 }
          end
        end,
        default_format_opts = {
          lsp_format = "fallback",
        },
        formatters_by_ft = {
          lua = { "stylua" },
          python = { "ruff_organize_imports", "black" },
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

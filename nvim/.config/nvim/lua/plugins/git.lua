return {
  "lewis6991/gitsigns.nvim",
  opts = {
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
  },
}

return {
  "nvim-tree/nvim-tree.lua",
  priority = 800,
  config = function()
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
        enable = true,
      },
      diagnostics = {
        enable = true,
        show_on_dirs = true,
      },
    })

    vim.keymap.set("n", "<C-n>", ":NvimTreeFindFileToggle<CR>")
  end,
}

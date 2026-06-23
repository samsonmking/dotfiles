return {
  { "junegunn/fzf", build = "./install --bin" },
  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons", "junegunn/fzf" },
    opts = {
      fzf_bin = vim.fn.stdpath("data") .. "/lazy/fzf/bin/fzf",
    },
  },
}

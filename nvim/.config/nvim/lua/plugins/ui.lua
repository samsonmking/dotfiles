return {
  { "nvim-tree/nvim-web-devicons", opt = true },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        theme = "onedark",
        section_separators = "",
        component_separators = "",
      },
      sections = {
        lualine_c = { { "filename", path = 1 } },
        lualine_x = { "filetype" },
      },
    },
  },
  { "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {} },
  {
    "navarasu/onedark.nvim",
    priority = 1000,
    opts = { style = "darker" },
  },
  {
    "nvim-mini/mini.cursorword",
    version = false,
    config = function()
      require('mini.cursorword').setup()
      -- Highlight (background) the word under the cursor instead of underlining it.
      -- Reapply on every ColorScheme so the colorscheme load order can't clobber it.
      local function set_cursorword_hl()
        local sp = require('onedark.palette').darker.fg
        vim.api.nvim_set_hl(0, 'MiniCursorword', { underline = true, sp = sp, bold = true })
        vim.api.nvim_set_hl(0, 'MiniCursorwordCurrent', { underline = true, sp = sp, bold = true })
      end
      vim.api.nvim_create_autocmd('ColorScheme', { pattern = '*', callback = set_cursorword_hl })
      set_cursorword_hl()
    end
  }
}

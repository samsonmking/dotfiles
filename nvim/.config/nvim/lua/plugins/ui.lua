return {
  {
    "nvim-mini/mini.icons",
    version = false,
    lazy = false,
    priority = 900, -- load before icon consumers
    config = function()
      require("mini.icons").setup()
      require("mini.icons").mock_nvim_web_devicons()
    end,
  },
  {
    "nvim-mini/mini.statusline",
    version = false,
    config = function()
      local statusline = require("mini.statusline")
      statusline.setup({
        use_icons = true,
        content = {
          -- Mirror the default active layout, but replace the fileinfo
          -- section with just the filetype (+ icon) so encoding, format,
          -- and file size are omitted.
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
              "%<", -- Mark general truncate point
              { hl = "MiniStatuslineFilename", strings = { filename } },
              "%=", -- End left alignment
              { hl = "MiniStatuslineFileinfo", strings = { filetype } },
              { hl = mode_hl, strings = { search, location } },
            })
          end,
        },
      })
    end,
  },
  { "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {} },
  {
    "nvim-treesitter/nvim-treesitter-context",
    opts = {
      max_lines = 3,
    },
  },
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

return {
  { "junegunn/fzf", build = "./install --bin" },
  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons", "junegunn/fzf" },
    opts = {
      fzf_bin = vim.fn.stdpath("data") .. "/lazy/fzf/bin/fzf",
      winopts = {
        preview = { layout = "vertical" },
      },
    },
    config = function(_, opts)
      require("fzf-lua").setup(opts)

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
      vim.keymap.set("n", "<leader>rc", function()
        vim.cmd("source $MYVIMRC")
        vim.notify("Config reloaded")
      end, { desc = "Reload config" })
      vim.keymap.set({ "i" }, "<C-x><C-f>", function()
        FzfLua.complete_file({
          winopts = { preview = { hidden = true } },
        })
      end, { silent = true, desc = "Fuzzy complete file" })
      vim.keymap.set({ "i" }, "<C-x><C-g>", function()
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
      vim.keymap.set({ "i" }, "<C-x><C-a>", function()
        FzfLua.complete_file({
          winopts = { preview = { hidden = true } },
          actions = {
            ["enter"] = function(selected, opts2)
              if not selected[1] then
                if opts2.__CTX and opts2.__CTX.mode == "i" then
                  vim.cmd([[noautocmd lua vim.api.nvim_feedkeys('i', 'n', true)]])
                end
                return
              end
              local orig_complete = opts2.complete
              opts2.complete = function(sel, o, l, c)
                local newline, newcol = orig_complete(sel, o, l, c)
                if not newline then
                  return
                end
                local match_pat = opts2.word_pattern or "[^%s\"']*"
                local before = c > 1 and (l:sub(1, c - 1):reverse():match(match_pat) or ""):reverse() or ""
                local path_start = c - #before - 1
                return newline:sub(1, path_start) .. "@" .. newline:sub(path_start + 1), newcol + 1
              end
              require("fzf-lua.actions").complete(selected, opts2)
            end,
          },
        })
      end, { silent = true, desc = "Fuzzy complete @file" })
    end,
  },
}

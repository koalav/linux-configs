return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local telescope = require("telescope")
      telescope.setup({})

      local map = vim.keymap.set
      map("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Find files" })
      map("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { desc = "Live grep" })
      map("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Buffers" })
      map("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { desc = "Help" })
    end,
  },
  {
    "kevinhwang91/nvim-hlslens",
    config = function()
      require("hlslens").setup({})
      local kopts = { noremap = true, silent = true }
      vim.api.nvim_set_keymap("n", "n", [[<cmd>execute('normal! ' . v:count1 . 'n')<cr><cmd>lua require('hlslens').start()<cr>]], kopts)
      vim.api.nvim_set_keymap("n", "N", [[<cmd>execute('normal! ' . v:count1 . 'N')<cr><cmd>lua require('hlslens').start()<cr>]], kopts)
      vim.api.nvim_set_keymap("n", "*", [[*<cmd>lua require('hlslens').start()<cr>]], kopts)
      vim.api.nvim_set_keymap("n", "#", [[#<cmd>lua require('hlslens').start()<cr>]], kopts)
      vim.api.nvim_set_keymap("n", "g*", [[g*<cmd>lua require('hlslens').start()<cr>]], kopts)
      vim.api.nvim_set_keymap("n", "g#", [[g#<cmd>lua require('hlslens').start()<cr>]], kopts)
    end,
  },
  {
    "MagicDuck/grug-far.nvim",
    config = function()
      require("grug-far").setup({})
      vim.keymap.set("n", "<leader>fr", "<cmd>GrugFar<cr>", { desc = "Find/Replace (grug-far)" })
    end,
  },
}

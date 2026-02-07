return {
  {
    "tversteeg/registers.nvim",
    config = function()
      require("registers").setup({})
      vim.keymap.set("n", "\"", "\"", { desc = "Registers popup" })
    end,
  },
  {
    "AckslD/nvim-neoclip.lua",
    dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
    config = function()
      require("neoclip").setup({
        history = 1000,
        enable_persistent_history = true,
      })
      pcall(require("telescope").load_extension, "neoclip")
      vim.keymap.set("n", "<leader>fy", "<cmd>Telescope neoclip<cr>", { desc = "Yank history" })
    end,
  },
}

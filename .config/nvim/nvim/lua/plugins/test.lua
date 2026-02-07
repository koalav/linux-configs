return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-neotest/nvim-nio",
      "nvim-treesitter/nvim-treesitter",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-neotest/neotest-jest",
      "nvim-neotest/neotest-python",
      "rcasia/neotest-java",
    },
    config = function()
      local neotest = require("neotest")

      local ok_jest, neotest_jest = pcall(require, "neotest-jest")
      local ok_py, neotest_python = pcall(require, "neotest-python")
      local ok_java, neotest_java = pcall(require, "neotest-java")

      local adapters = {}
      if ok_jest then
        table.insert(adapters, neotest_jest({
          jestCommand = "npm test --",
          env = { CI = true },
        }))
      end
      if ok_py then
        table.insert(adapters, neotest_python({
          runner = "pytest",
        }))
      end
      if ok_java then
        table.insert(adapters, neotest_java({
          junit_jar = vim.fn.stdpath("data") .. "/neotest-java/junit-platform-console-standalone.jar",
        }))
      end

      neotest.setup({
        adapters = adapters,
      })

      vim.keymap.set("n", "<leader>tt", function() neotest.run.run() end, { desc = "Test: run nearest" })
      vim.keymap.set("n", "<leader>tT", function() neotest.run.run(vim.fn.expand("%")) end, { desc = "Test: run file" })
      vim.keymap.set("n", "<leader>to", function() neotest.output.open({ enter = true }) end, { desc = "Test: output" })
      vim.keymap.set("n", "<leader>ts", function() neotest.summary.toggle() end, { desc = "Test: summary" })
      vim.keymap.set("n", "<leader>tS", function() neotest.run.stop() end, { desc = "Test: stop" })
    end,
  },
}

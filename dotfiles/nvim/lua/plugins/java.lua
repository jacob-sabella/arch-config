return {
  {
    "nvim-java/nvim-java",
    ft = "java",
    dependencies = {
      "nvim-java/nvim-java-core",
      "nvim-java/nvim-java-test",
      "nvim-java/nvim-java-dap",
      "nvim-java/nvim-java-refactor",
      "MunifTanjim/nui.nvim",
      "mfussenegger/nvim-dap",
      "JavaHello/spring-boot.nvim",
    },
    config = function()
      -- Define breakpoint signs FIRST (before any potential errors)
      vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DapBreakpoint", linehl = "", numhl = "" })
      vim.fn.sign_define("DapBreakpointCondition", { text = "●", texthl = "DapBreakpointCondition", linehl = "", numhl = "" })
      vim.fn.sign_define("DapBreakpointRejected", { text = "●", texthl = "DapBreakpointRejected", linehl = "", numhl = "" })
      vim.fn.sign_define("DapStopped", { text = "→", texthl = "DapStopped", linehl = "DapStoppedLine", numhl = "" })
      vim.fn.sign_define("DapLogPoint", { text = "◆", texthl = "DapLogPoint", linehl = "", numhl = "" })
      vim.api.nvim_set_hl(0, "DapBreakpoint", { fg = "#e51400" })
      vim.api.nvim_set_hl(0, "DapBreakpointCondition", { fg = "#f9a825" })
      vim.api.nvim_set_hl(0, "DapBreakpointRejected", { fg = "#757575" })
      vim.api.nvim_set_hl(0, "DapStopped", { fg = "#98c379" })
      vim.api.nvim_set_hl(0, "DapStoppedLine", { bg = "#2e4d3d" })
      vim.api.nvim_set_hl(0, "DapLogPoint", { fg = "#61afef" })

      -- Setup nvim-java with error handling
      local ok, err = pcall(function()
        require("java").setup({
          jdtls = { version = "1.43.0" },
          lombok = { enable = true, version = "1.18.40" },
          java_test = { enable = true, version = "0.40.1" },
          java_debug_adapter = { enable = true, version = "0.58.2" },
          spring_boot_tools = { enable = true, version = "1.55.1" },
          jdk = { auto_install = false },
        })
      end)
      if not ok then
        vim.notify("nvim-java setup error: " .. tostring(err), vim.log.levels.ERROR)
      end
      -- nvim-java handles jdtls LSP setup automatically, don't call vim.lsp.enable
    end,
  },
  -- Exclude jdtls from mason-lspconfig (nvim-java handles it)
  {
    "williamboman/mason-lspconfig.nvim",
    opts = function(_, opts)
      opts.automatic_enable = opts.automatic_enable or {}
      if type(opts.automatic_enable) == "boolean" then
        opts.automatic_enable = { exclude = { "jdtls" } }
      else
        opts.automatic_enable.exclude = opts.automatic_enable.exclude or {}
        table.insert(opts.automatic_enable.exclude, "jdtls")
      end
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        jdtls = {},
      },
      setup = {
        jdtls = function()
          return true -- avoid duplicate setup, nvim-java handles it
        end,
      },
    },
  },
  -- DAP UI for debugging interface
  {
    "rcarriga/nvim-dap-ui",
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-neotest/nvim-nio",
    },
    keys = {
      { "<leader>du", function() require("dapui").toggle({}) end, desc = "DAP UI Toggle" },
      { "<leader>de", function() require("dapui").eval() end, desc = "DAP Eval", mode = { "n", "v" } },
    },
    opts = {},
    config = function(_, opts)
      local dap = require("dap")
      local dapui = require("dapui")
      dapui.setup(opts)
      -- Auto open/close DAP UI
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open({})
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close({})
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close({})
      end
    end,
  },
  -- Virtual text for debugging
  {
    "theHamsta/nvim-dap-virtual-text",
    dependencies = { "mfussenegger/nvim-dap", "nvim-treesitter/nvim-treesitter" },
    opts = {},
  },
  -- DAP keymaps
  {
    "mfussenegger/nvim-dap",
    ft = "java",
    keys = {
      { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: ")) end, desc = "Breakpoint Condition" },
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
      { "<leader>dc", function() require("dap").continue() end, desc = "Continue" },
      { "<leader>dC", function() require("dap").run_to_cursor() end, desc = "Run to Cursor" },
      { "<leader>dg", function() require("dap").goto_() end, desc = "Go to Line (No Execute)" },
      { "<leader>di", function() require("dap").step_into() end, desc = "Step Into" },
      { "<leader>dj", function() require("dap").down() end, desc = "Down" },
      { "<leader>dk", function() require("dap").up() end, desc = "Up" },
      { "<leader>dl", function() require("dap").run_last() end, desc = "Run Last" },
      { "<leader>do", function() require("dap").step_out() end, desc = "Step Out" },
      { "<leader>dO", function() require("dap").step_over() end, desc = "Step Over" },
      { "<leader>dp", function() require("dap").pause() end, desc = "Pause" },
      { "<leader>dr", function() require("dap").repl.toggle() end, desc = "Toggle REPL" },
      { "<leader>ds", function() require("dap").session() end, desc = "Session" },
      { "<leader>dt", function() require("dap").terminate() end, desc = "Terminate" },
      { "<leader>dw", function() require("dap.ui.widgets").hover() end, desc = "Widgets" },
    },
  },
  -- Java-specific debug/test keymaps
  {
    "nvim-java/nvim-java",
    keys = {
      { "<leader>Jc", function() require("java").dap.config_dap() end, desc = "Java: Configure DAP" },
      { "<leader>Jt", function() require("java").test.run_current_class() end, desc = "Java: Test Class" },
      { "<leader>JT", function() require("java").test.run_current_method() end, desc = "Java: Test Method" },
      { "<leader>Jd", function() require("java").test.debug_current_class() end, desc = "Java: Debug Test Class" },
      { "<leader>JD", function() require("java").test.debug_current_method() end, desc = "Java: Debug Test Method" },
      { "<leader>Jr", function() require("java").runner.built_in.run_app({}) end, desc = "Java: Run App" },
      { "<leader>JR", function() require("java").runner.built_in.toggle_logs() end, desc = "Java: Toggle Logs" },
      { "<leader>Js", function() require("java").runner.built_in.stop_app() end, desc = "Java: Stop App" },
    },
  },
}

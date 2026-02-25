return {
  "nvim-neo-tree/neo-tree.nvim",
  cmd = "Neotree",
  init = function()
    -- Don't fully disable netrw - we need it for scp:// remote file editing
    -- Just prevent it from hijacking directory browsing
    vim.g.netrw_browse_split = 0
    vim.g.netrw_banner = 0
    vim.g.netrw_liststyle = 0
  end,
  config = function()
    require("neo-tree").setup({
      filesystem = {
        -- Don't hijack anything - use <leader>e to open neo-tree
        hijack_netrw_behavior = "disabled",
        filtered_items = {
          hide_dotfiles = false,
        },
      },
      -- Prevent neo-tree from replacing oil or other special buffers
      open_files_do_not_replace_types = { "terminal", "trouble", "qf", "oil" },
      window = {
        mappings = {
          -- Allow <leader> to pass through to global keymaps
          ["<leader>"] = "none",
          -- Push selected file to remote oil SSH directory
          ["P"] = {
            function(state)
              local node = state.tree:get_node()
              if node and node.path then
                if node.type == "file" then
                  vim.cmd("SshPush " .. vim.fn.fnameescape(node.path))
                else
                  vim.notify("Select a file, not a directory", vim.log.levels.WARN)
                end
              end
            end,
            desc = "Push to remote (SSH)",
          },
        },
      },
    })
  end,
}

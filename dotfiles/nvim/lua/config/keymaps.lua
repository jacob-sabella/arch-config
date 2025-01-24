-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Create command for FTerm toggle
vim.api.nvim_create_user_command("FTermToggle", require("FTerm").toggle, { bang = true })

-- Map Alt+\ to FTermToggle
vim.keymap.set({ "n", "t" }, "<C-\\>", "<cmd>FTermToggle<cr>", { desc = "Toggle FTerm" })

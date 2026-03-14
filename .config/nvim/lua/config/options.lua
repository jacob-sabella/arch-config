-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.opt.exrc = true
vim.opt.secure = true

-- Disable all auto-formatting
vim.g.autoformat = false

-- Disable LSP inlay hints
vim.g.lazyvim_inlay_hints = false
vim.lsp.inlay_hint.enable(false)

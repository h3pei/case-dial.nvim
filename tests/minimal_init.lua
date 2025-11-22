-- Minimal init for testing
vim.cmd([[set runtimepath+=.]])
vim.cmd([[set runtimepath+=~/.local/share/nvim/lazy/plenary.nvim]])

-- Basic settings for testing
vim.o.swapfile = false
vim.o.hidden = true

-- Load the plugin
require("case-dial")

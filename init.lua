-- Run with: nvim
if vim.fn.has("nvim-0.12") == 0 then
  error("This config requires Neovim 0.12 or newer")
end

vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("config.options")
require("config.keymaps")
require("config.autocmds")
require("plugins").setup()
require("languages").setup()
require("config.git_status").setup()

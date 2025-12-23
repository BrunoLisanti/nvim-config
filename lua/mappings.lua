vim.g.mapleader = " "
vim.api.nvim_set_keymap('n', '<CR>', ':w | !./build.sh<CR>', { noremap = true, silent = true})

vim.api.nvim_set_keymap('n', '<BS>', ':Oil<CR>', { noremap = true, silent = true});


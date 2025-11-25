vim.g.mapleader = " "
vim.api.nvim_set_keymap('n', '<CR>', ':w | !./build.sh<CR>', { noremap = true, silent = true})

vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "LSP Code Action"})
vim.keymap.set("v", "<leader>ca", vim.lsp.buf.code_action, { desc = "LSP Code Action"})

-- Autocmds
vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function()
    vim.opt_local.expandtab = true
  end
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "dart", "html", "yaml", "json", "css" },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.shiftwidth = 2
  end
})

-- Diagnósticos
vim.diagnostic.config({
  update_in_insert = true,
  virtual_text = true,
  signs = true,
  underline = true,
  severity_sort = true
})

-- Mapeos
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('t', '<Esc>', '<C-\\><C-n>:ToggleTerm<CR>')
vim.keymap.set('n', '<C-t>', ':ToggleTerm direction = float<CR>')
vim.keymap.set('n', '<CR>', ':w | !./build.sh<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<BS>', '<cmd>Oil<CR>', { desc = 'Open Oil file browser' })


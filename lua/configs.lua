vim.g.mapleader = " "
vim.o.number = true
vim.o.relativenumber = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.list = true
vim.opt.signcolumn = "yes"
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.o.scrolloff = 10
vim.o.undofile = true
vim.o.showmode = false

vim.schedule(function()
	vim.o.clipboard = 'unnamedplus'
end)

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = false

--Casos en que hay que usar espacios
vim.api.nvim_create_autocmd("FileType", {
	pattern = "python",
	callback = function()
		vim.opt_local.expandtab = true 
	end
})

--Casos en que hay que usar ancho 2
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "dart", "html", "yaml", "json", "css"},
	callback = function()
		vim.opt_local.tabstop = 2
		vim.opt_local.softtabstop = 2
		vim.opt_local.shiftwidth = 2
	end
})

vim.opt.swapfile = false
vim.opt.updatetime = 300
vim.opt.breakindent = true

vim.o.confirm = true

vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

vim.diagnostic.config(
{
	update_in_insert = true,
	virtual_text = true,
	signs = true,
	underline = true,
	severity_sort = true
})



vim.loader.enable()

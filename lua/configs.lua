vim.g.mapleader = " "
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.smartcase = true

--Configuracion por defecto
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = false
vim.opt.signcolumn = "yes"

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

vim.diagnostic.config(
{
	update_in_insert = true,
	virtual_text = true,
	signs = true,
	underline = true,
	severity_sort = true
})

vim.loader.enable()

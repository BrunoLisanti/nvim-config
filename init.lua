vim.g.mapleader = " "

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.runtimepath:prepend(lazypath)

-- Opciones
vim.o.number = true
vim.o.relativenumber = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.list = true
vim.opt.signcolumn = "yes"
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.o.undofile = true
vim.o.showmode = false
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = false
vim.opt.swapfile = false
vim.opt.updatetime = 300
vim.opt.breakindent = true
vim.o.confirm = true
vim.opt.shortmess:append('I')
vim.loader.enable()

vim.schedule(function()
	vim.o.clipboard = 'unnamedplus'
end)

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

-- Mappings globales
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('n', '<CR>', ':w | !./build.sh<CR>', { noremap = true, silent = true })

-- Diagnósticos
vim.diagnostic.config({
	update_in_insert = true,
	virtual_text = true,
	signs = true,
	underline = true,
	severity_sort = true
})

-- Plugins
require("lazy").setup({
	spec = {
		{
			"jinzhongjia/zig-lamp",
			event = "VeryLazy",
			build = ":ZigLampBuild async",
			dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
			init = function()
				vim.g.zig_lamp_pkg_help_fg = "#CF5C00"
				vim.g.zig_lamp_zig_fetch_timeout = 5000
			end,
		},
		{
			'vague-theme/vague.nvim',
			lazy = false,
			priority = 1000,
			config = function()
				vim.cmd.colorscheme('vague')
			end
		},
		{
			'nvim-treesitter/nvim-treesitter',
			build = ':TSUpdate',
			opts = {
				ensure_installed = { "cpp", "c", "javascript", "typescript", "glsl", "html", "css", "dart", "zig" },
				auto_install = true,
				highlight = {
					enable = true,
					additional_vim_regex_highlighting = { 'ruby' },
				},
				indent = { enable = true, disable = { 'ruby' } },
			},
		},
		{
			'windwp/nvim-ts-autotag',
			opts = {},
		},
		{
			'nvim-telescope/telescope.nvim',
			event = 'VimEnter',
			dependencies = {
				'nvim-lua/plenary.nvim',
				{ 'nvim-telescope/telescope-fzf-native.nvim', build = 'make', cond = function() return vim.fn.executable 'make' == 1 end },
				'nvim-telescope/telescope-ui-select.nvim',
				{ 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
			},
			config = function()
				require('telescope').setup {
					extensions = {
						['ui-select'] = {
							require('telescope.themes').get_dropdown(),
						},
					},
				}

				pcall(require('telescope').load_extension, 'fzf')
				pcall(require('telescope').load_extension, 'ui-select')

				local builtin = require 'telescope.builtin'
				vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
				vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
				vim.keymap.set('n', '<leader>f', builtin.find_files, { desc = '[S]earch [F]iles' })
				vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
				vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
				vim.keymap.set('n', '<leader>g', builtin.live_grep, { desc = '[S]earch by [G]rep' })
				vim.keymap.set('n', '<leader>m', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
				vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
				vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
				vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

				vim.keymap.set('n', '<leader>/', function()
					builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
						winblend = 10,
						previewer = false,
					})
				end, { desc = '[/] Fuzzily search in current buffer' })

				vim.keymap.set('n', '<leader>s/', function()
					builtin.live_grep {
						grep_open_files = true,
						prompt_title = 'Live Grep in Open Files',
					}
				end, { desc = '[S]earch [/] in Open Files' })

				vim.keymap.set('n', '<leader>sn', function()
					builtin.find_files { cwd = vim.fn.stdpath 'config' }
				end, { desc = '[S]earch [N]eovim files' })
			end,
		},
		{
			"neovim/nvim-lspconfig",
			dependencies = {
				{ 'mason-org/mason.nvim', opts = {} },
				'mason-org/mason-lspconfig.nvim',
				'WhoIsSethDaniel/mason-tool-installer.nvim',
				{ 'j-hui/fidget.nvim', opts = {} },
				{ "folke/lazydev.nvim", ft = "lua", opts = {} },
			},
			config = function()
				local function client_supports_method(client, method, bufnr)
					if vim.fn.has 'nvim-0.11' == 1 then
						return client:supports_method(method, bufnr)
					else
						return client.supports_method(method, { bufnr = bufnr })
					end
				end

				vim.api.nvim_create_autocmd("LspAttach", {
					group = vim.api.nvim_create_augroup("UserLspConfig", {}),
					callback = function(args)
						local opts = { buffer = args.buf }
						vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
						vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
						vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
						vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, opts)
						vim.keymap.set("n", "<leader>.", vim.lsp.buf.code_action, opts)

						local client = vim.lsp.get_client_by_id(args.data.client_id)
						if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, args.buf) then
							local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
							vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
								buffer = args.buf,
								group = highlight_augroup,
								callback = vim.lsp.buf.document_highlight,
							})

							vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
								buffer = args.buf,
								group = highlight_augroup,
								callback = vim.lsp.buf.clear_references,
							})

							vim.api.nvim_create_autocmd('LspDetach', {
								group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
								callback = function(event2)
									vim.lsp.buf.clear_references()
									vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
								end,
							})
						end
					end
				})

				local capabilities = require('blink.cmp').get_lsp_capabilities()
				local servers = {
					clangd = {},
					html = {},
					ts_ls = {},
					eslint = {},
					cssls = {},
					mypy = {},
					djlint = {},
				}
				local ensure_installed = vim.tbl_keys(servers or {})
				require('mason-tool-installer').setup { ensure_installed = ensure_installed }

				require('mason-lspconfig').setup {
					ensure_installed = {},
					automatic_installation = false,
					handlers = {
						function(server_name)
							local server = servers[server_name] or {}
							server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
							require('lspconfig')[server_name].setup(server)
						end,
					},
				}
			end
		},
		{
			'saghen/blink.cmp',
			event = 'VimEnter',
			version = '1.*',
			opts = {
				keymap = { preset = 'enter' },
				appearance = { nerd_font_variant = 'mono' },
				completion = { documentation = { auto_show = false, auto_show_delay_ms = 500 } },
				sources = {
					default = { 'lsp', 'path', 'lazydev' },
					providers = { lazydev = { module = 'lazydev.integrations.blink', score_offset = 100 } },
				},
				fuzzy = { implementation = 'lua' },
				signature = { enabled = true },
			},
		},
		{
			"windwp/nvim-autopairs",
			opts = {},
		},
		{
			'nvim-flutter/flutter-tools.nvim',
			ft = { "dart" },
			dependencies = { 'nvim-lua/plenary.nvim', 'stevearc/dressing.nvim' },
			opts = {},
		},
		{
			'stevearc/oil.nvim',
			keys = {
				{ "<BS>", "<cmd>Oil<CR>", desc = "Open Oil file browser" },
			},
			opts = {},
		},
		{
			'echasnovski/mini.statusline',
			config = function()
				local statusline = require 'mini.statusline'
				statusline.setup { use_icons = vim.g.have_nerd_font }
				---@diagnostic disable-next-line: duplicate-set-field
				statusline.section_location = function()
					return '%2l:%-2v'
				end
			end,
		},
	},
	ui = {
		icons = vim.g.have_nerd_font and {} or {
			cmd = '⌘',
			config = '🛠',
			event = '📅',
			ft = '📂',
			init = '⚙',
			keys = '🗝',
			plugin = '🔌',
			runtime = '💻',
			require = '🌙',
			source = '📄',
			start = '🚀',
			task = '📌',
			lazy = '💤 ',
		},
	}
})

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out,                            "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.runtimepath:prepend(lazypath)

require("utils")
require("mappings")
require("configs")

require("lazy").setup(
	{
		spec = {
			{
				"folke/tokyonight.nvim",

				config = function()
					require("tokyonight").setup({
						transparent = true
					})
					vim.cmd.colorscheme "tokyonight-night"
				end
			},
			{
				'nvim-treesitter/nvim-treesitter',
				build = ':TSUpdate',
				main = 'nvim-treesitter.configs', -- Sets main module to use for opts
				-- [[ Configure Treesitter ]] See `:help nvim-treesitter`
				opts = {
				ensure_installed = { "cpp", "c", "javascript", "typescript", "glsl", "html", "css", "dart" },
				-- Autoinstall languages that are not installed
				auto_install = true,
				highlight = {
					enable = true,
					-- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
					--  If you are experiencing weird indenting issues, add the language to
					--  the list of additional_vim_regex_highlighting and disabled languages for indent.
					additional_vim_regex_highlighting = { 'ruby' },
				},
				indent = { enable = true, disable = { 'ruby' } },
    },
			},
			{ -- Fuzzy Finder (files, lsp, etc)
				'nvim-telescope/telescope.nvim',
				event = 'VimEnter',
				dependencies = {
				  'nvim-lua/plenary.nvim',
				  { -- If encountering errors, see telescope-fzf-native README for installation instructions
					'nvim-telescope/telescope-fzf-native.nvim',

					-- `build` is used to run some command when the plugin is installed/updated.
					-- This is only run then, not every time Neovim starts up.
					build = 'make',

					-- `cond` is a condition used to determine whether this plugin should be
					-- installed and loaded.
					cond = function()
					  return vim.fn.executable 'make' == 1
					end,
				  },
				  { 'nvim-telescope/telescope-ui-select.nvim' },

				  -- Useful for getting pretty icons, but requires a Nerd Font.
				  { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
				},
				config = function()
				  -- Telescope is a fuzzy finder that comes with a lot of different things that
				  -- it can fuzzy find! It's more than just a "file finder", it can search
				  -- many different aspects of Neovim, your workspace, LSP, and more!
				  --
				  -- The easiest way to use Telescope, is to start by doing something like:
				  --  :Telescope help_tags
				  --
				  -- After running this command, a window will open up and you're able to
				  -- type in the prompt window. You'll see a list of `help_tags` options and
				  -- a corresponding preview of the help.
				  --
				  -- Two important keymaps to use while in Telescope are:
				  --  - Insert mode: <c-/>
				  --  - Normal mode: ?
				  --
				  -- This opens a window that shows you all of the keymaps for the current
				  -- Telescope picker. This is really useful to discover what Telescope can
				  -- do as well as how to actually do it!

				  -- [[ Configure Telescope ]]
				  -- See `:help telescope` and `:help telescope.setup()`
				  require('telescope').setup {
					-- You can put your default mappings / updates / etc. in here
					--  All the info you're looking for is in `:help telescope.setup()`
					--
					-- defaults = {
					--   mappings = {
					--     i = { ['<c-enter>'] = 'to_fuzzy_refine' },
					--   },
					-- },
					-- pickers = {}
					extensions = {
					  ['ui-select'] = {
						require('telescope.themes').get_dropdown(),
					  },
					},
				  }

				  -- Enable Telescope extensions if they are installed
				  pcall(require('telescope').load_extension, 'fzf')
				  pcall(require('telescope').load_extension, 'ui-select')

				  -- See `:help telescope.builtin`
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

				  -- Slightly advanced example of overriding default behavior and theme
				  vim.keymap.set('n', '<leader>/', function()
					-- You can pass additional configuration to Telescope to change the theme, layout, etc.
					builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
					  winblend = 10,
					  previewer = false,
					})
				  end, { desc = '[/] Fuzzily search in current buffer' })

				  -- It's also possible to pass additional configuration options.
				  --  See `:help telescope.builtin.live_grep()` for information about particular keys
				  vim.keymap.set('n', '<leader>s/', function()
					builtin.live_grep {
					  grep_open_files = true,
					  prompt_title = 'Live Grep in Open Files',
					}
				  end, { desc = '[S]earch [/] in Open Files' })

				  -- Shortcut for searching your Neovim configuration files
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
					'saghen/blink.cmp',
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
					vim.keymap.set("n", "<leader>m", function()
						vim.diagnostic.jump({ count = 1 })
					end)
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
						biome = {},
						rust_analyzer = {},
						mypy = {},
						ts_ls = {},
						pylsp = {},
					}
					local ensure_installed = vim.tbl_keys(servers or {})
					require('mason-tool-installer').setup { ensure_installed = ensure_installed }

					require('mason-lspconfig').setup {
					  ensure_installed = {}, -- explicitly set to an empty table (Kickstart populates installs via mason-tool-installer)
					  automatic_installation = false,
					  handlers = {
					    function(server_name)
					  	local server = servers[server_name] or {}
					  	-- This handles overriding only values explicitly passed
					  	-- by the server configuration above. Useful when disabling
					  	-- certain features of an LSP (for example, turning off formatting for ts_ls)
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
				dependencies = {
				  {
					'L3MON4D3/LuaSnip',
					version = '2.*',
					build = (function()
					  -- Build Step is needed for regex support in snippets.
					  -- This step is not supported in many windows environments.
					  -- Remove the below condition to re-enable on windows.
					  if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
						return
					  end
					  return 'make install_jsregexp'
					end)(),
					dependencies = {
					  {
					    'rafamadriz/friendly-snippets',
					    config = function()
					      require('luasnip.loaders.from_vscode').lazy_load()
					    end,
					  },
					},
					opts = {},
				  },
					'folke/lazydev.nvim',
				},
				opts = {
					keymap = {
						preset = 'enter'
					},
					appearance = {
						nerd_font_variant = 'mono',
					},
					completion = {
						documentation = { auto_show = false, auto_show_delay_ms = 500 },
					},
				    sources = {
				      default = { 'lsp', 'path', 'snippets', 'lazydev' },
				      providers = {
				        lazydev = { module = 'lazydev.integrations.blink', score_offset = 100 },
				      },
				    },

					snippets = { preset = 'luasnip' },
					fuzzy = { implementation = 'lua' },
					signature = { enabled = true }
				}
			},
			{
				"windwp/nvim-autopairs",
				config = function()
					require("nvim-autopairs").setup()
				end
			},
			{ 
				'nvim-flutter/flutter-tools.nvim',
				lazy = false,
				dependencies = {
					'nvim-lua/plenary.nvim',
					'stevearc/dressing.nvim', -- optional for vim.ui.select
				},
				config = true,
				opts = {
					cmd = {
						"dart",
						"language-server",
						"--protocol=lsp"
					},
				},
			--		require("flutter-tools").setup()
			},
			{
				'stevearc/oil.nvim',
				config = function()
					require('oil').setup({})
				end
			},
			{ -- Collection of various small independent plugins/modules
			  'echasnovski/mini.nvim',
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

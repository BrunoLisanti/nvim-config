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
				"nvim-treesitter/nvim-treesitter",
				build = ":TSUpdate",
				config = function()
					require("nvim-treesitter.configs").setup(
						{
							auto_install = true,
							ensure_installed = { "cpp", "c", "javascript", "typescript", "glsl", "html", "css" },
							highlight = { enable = true },
							indent = { enable = true },
						})
				end
			},
			{
				"nvim-telescope/telescope.nvim",
				dependencies =
				{
					{ "nvim-lua/plenary.nvim" },
					{ "nvim-telescope/telescope-fzf-native.nvim", build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release" }
				},
				config = function()
					local telescope_builtin = require("telescope.builtin")
					vim.keymap.set("n", "<Leader>f", function()
						telescope_builtin.find_files({ cwd = GetTelescopeDir() })
					end)
					vim.keymap.set("n", "<Leader>g", function()
						telescope_builtin.live_grep({ cwd = GetTelescopeDir() })
					end)

					require("telescope").setup(
						{
							defaults =
							{
								preview =
								{
									treesitter = false
								}
							},
							extensions =
							{
								fzf =
								{
									fuzzy = true,
									override_generic_sorter = true,
									override_file_sorter = true,
									case_mode = "smart_case"
								}
							}
						})
				end
			},
			{
				"lukas-reineke/indent-blankline.nvim",
				main = "ibl",
				config = function()
					local highlight = {
						"IndentBlanklineIndent1",
						"IndentBlanklineIndent2",
					}

					vim.api.nvim_set_hl(0, "IndentBlanklineIndent1", { fg = "#3b4261" })
					vim.api.nvim_set_hl(0, "IndentBlanklineIndent2", { fg = "#2f3549" })

					require("ibl").setup({
						indent = {
							char = "·",
							highlight = highlight,
							smart_indent_cap = true,
						},
						scope = {
							enabled = true,
							show_start = false,
							show_end = false,
						},
					})
				end
			},
			{
				"neovim/nvim-lspconfig",
				version = "v2.5.0",
				dependencies = {
					"williamboman/mason.nvim",
					"williamboman/mason-lspconfig.nvim",
					"hrsh7th/nvim-cmp",
					"hrsh7th/cmp-buffer",
					"hrsh7th/cmp-path",
					"hrsh7th/cmp-nvim-lua",
					"hrsh7th/cmp-nvim-lsp",
					"hrsh7th/cmp-cmdline",
					"L3MON4D3/LuaSnip",
					"saadparwaiz1/cmp_luasnip",
					"stevearc/conform.nvim",
					"windwp/nvim-ts-autotag",
					{ "folke/lazydev.nvim", ft = "lua", opts = {} },
				},
				config = function()
					require("mason").setup()
					local capabilities = require("cmp_nvim_lsp").default_capabilities()

					require("mason-lspconfig").setup({
						ensure_installed = {
							"lua_ls", "clangd", "glsl_analyzer", "ts_ls", "biome"
						}
					})

					require("lspconfig").lua_ls.setup({
						capabilities = capabilities,
					})

					require("lspconfig").clangd.setup({
						cmd = {
							"clangd",
							"--background-index",
							"--clang-tidy",
							"--header-insertion=never",
						},
						filetypes = { "c", "h", "cpp", "hpp", "objc", "objcpp" },
						capabilities = capabilities,
						init_options = {
							compilationDatabasePath = "./build",
						},
						on_attach = function(client)
							client.server_capabilities.documentFormattingProvider = false
						end
					})

					require("lspconfig").glsl_analyzer.setup({
						filetypes = { "glsl", "vert", "frag" },
						capabilities = capabilities,
					})

					require("lspconfig").ts_ls.setup({
						cmd = { "typescript-language-server", "--stdio" },
						filetypes = { "javascript", "typescript" },
						capabilities = capabilities
					})

					require("lspconfig").biome.setup({
						filetypes = { "css", "html", "json", "jsonc" },
						capabilities = capabilities
					})

					local mason_registry = require("mason-registry")
					-- if not mason_registry.is_installed("clang-format") then
					-- 	vim.cmd("MasonInstall clang-format")
					-- end

					-- require("conform").setup({
					-- 	formatters = {
					-- 		clang_format = {
					-- 			command = "clang-format",
					-- 			args = {
					-- 				"--style={BasedOnStyle: GNU, UseTab: Always, IndentWidth: 4, TabWidth: 4}"
					-- 			},
					-- 			stdin = true,
					-- 		}
					-- 	},
					-- 	formatters_by_ft = {
					-- 		c = { "clang_format" },
					-- 		cpp = { "clang_format" },
					-- 		h = { "clang_format" },
					-- 		hpp = { "clang_format" },
					-- 		glsl = { "clang_format" },
					--
					-- 		javascript = { "biome" },
					-- 		typescript = { "biome" },
					-- 	},
					-- 	format_on_save = {
					-- 		timeout_ms = 1000,
					-- 		lsp_fallback = false,
					-- 	}
					-- })

					vim.keymap.set("n", "<leader>m", function()
						vim.diagnostic.jump({ count = 1 })
					end)
					vim.api.nvim_create_autocmd("LspAttach", {
						group = vim.api.nvim_create_augroup("UserLspConfig", {}),
						callback = function(args)
							local client = vim.lsp.get_client_by_id(args.data.client_id)
							if not client then return end

							local opts = { buffer = args.buf }
							vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
							vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
							vim.keymap.set("n", "gh", vim.lsp.buf.hover, opts)
							vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, opts)
							vim.keymap.set("n", "<C-.>", vim.lsp.buf.code_action, opts)
						end
					})

					--Autocerrar etiquetas html
					require("nvim-ts-autotag").setup()

					--Snippets
					local ls = require("luasnip")
					ls.config.set_config({
						history = true,
						update_events = "TextChanged, TextChangedI",
						enable_autosnippets = true
					})

					--completado
					local cmp = require("cmp")
					cmp.setup({
						performance = {
							debounce = 60,
							throttle = 30,
							async_budget = 1,
							fetching_timeout = 500,
							confirm_resolve_timeout = 80,
							max_view_entries = 10,
							filtering_context_budget = 0
						},
						snippet = {
							expand = function(args)
								ls.lsp_expand(args.body)
							end
						},
						mapping = cmp.mapping.preset.insert({
							["<C-Space>"] = cmp.mapping.complete(),
							["<C-e>"] = cmp.mapping.abort(),
							["<CR>"] = cmp.mapping.confirm({ select = false }),
							["<C-n>"] = cmp.mapping.select_next_item(),
							["<C-p>"] = cmp.mapping.select_prev_item(),
							["<Tab>"] = cmp.mapping.select_next_item(),
							["<S-Tab>"] = cmp.mapping.select_prev_item(),
						}),
						sources = cmp.config.sources({
							{ name = "luasnip" },
							{ name = "nvim_lua" },
							{ name = "nvim_lsp" },
							{ name = "buffer" },
							{ name = "path" },
						}),
					})
					local cmp_autopairs = require("nvim-autopairs.completion.cmp")
					cmp.event:on(
						"confirm_done",
						cmp_autopairs.on_confirm_done()
					)
				end
			},
			{
				"kylechui/nvim-surround",
				version = "*",
				event = "VeryLazy",
				config = function()
					require("nvim-surround").setup({
						keymaps = {
							normal = "s",
							normal_cur = "ss",
							normal_line = "S",
							normal_cur_line = "SS",
							visual = "s",
							visual_line = "S",
							delete = "ds",
							change = "cs",
						},
					})
				end
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
				config = function()
					require("flutter-tools").setup()
				end
			}
		},
	})

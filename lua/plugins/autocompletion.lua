local capabilities = require('blink.cmp').get_lsp_capabilities()
local servers = {
  clangd = {},
  html = {},
  ts_ls = {},
  eslint = {},
  cssls = {},
}
for server, opts in pairs(servers) do
  opts.capabilities = vim.tbl_deep_extend('force', {}, capabilities, opts.capabilities or {})
  vim.lsp.config(server, opts)
end

require('blink.cmp').setup({
	keymap = {
    preset = 'super-tab',
    -- -- Navegar hacia abajo en la lista
    -- ['<C-n>'] = { 'select_next', 'fallback' },
    -- -- Navegar hacia arriba en la lista (recomendado)
    -- ['<C-p>'] = { 'select_prev', 'fallback' },
    -- -- Aceptar la sugerencia. El 'fallback' asegura que si el menú 
    -- -- está cerrado, la tecla Tab funcione normalmente en tu código.
    -- ['<Tab>'] = { 'accept', 'fallback' },
    -- ['<CR>'] = { 'fallback' }
  },
  appearance = { nerd_font_variant = 'mono' },
  completion = { documentation = { auto_show = false, auto_show_delay_ms = 0 } },
  sources = {
    default = { 'lsp', 'path' },
  },
  fuzzy = { implementation = 'lua' },
  signature = { enabled = true },
})

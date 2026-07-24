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

-- Config: Blink Completado
require('blink.cmp').setup({
  keymap = { preset = 'enter' },
  appearance = { nerd_font_variant = 'mono' },
  completion = { documentation = { auto_show = false, auto_show_delay_ms = 500 } },
  sources = {
    default = { 'lsp', 'path' },
  },
  fuzzy = { implementation = 'lua' },
  signature = { enabled = true },
})

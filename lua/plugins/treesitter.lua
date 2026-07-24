
-- Config: Treesitter
require('nvim-treesitter').setup({
  ensure_installed = { 
	  "cpp",
	  "c",
	  "javascript",
	  "typescript",
	  "glsl",
	  "html",
	  "css",
	  "dart",
	  "zig"
  },
  highlight = { enable = true, },
})

-- Hook para nvim-treesitter: actualizar parsers después de update
vim.api.nvim_create_autocmd('PackChanged', { callback = function(ev)
  local name, kind = ev.data.spec.name, ev.data.kind
  if name == 'nvim-treesitter' and kind == 'update' then
    if not ev.data.active then vim.cmd.packadd('nvim-treesitter') end
    vim.cmd('TSUpdate')
  end
end })

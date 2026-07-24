require('options')
require('configs')

vim.pack.add({
  -- Tema
  'https://github.com/vague-theme/vague.nvim',

  -- Dependencias comunes
  'https://github.com/nvim-lua/plenary.nvim',

  -- Treesitter
  'https://github.com/nvim-treesitter/nvim-treesitter',

  -- Telescope y dependencias
  'https://github.com/nvim-telescope/telescope-fzf-native.nvim',
  'https://github.com/nvim-telescope/telescope-ui-select.nvim',
  'https://github.com/nvim-tree/nvim-web-devicons',
  'https://github.com/nvim-telescope/telescope.nvim',

  -- LSP y dependencias
  'https://github.com/mason-org/mason.nvim',
  'https://github.com/mason-org/mason-lspconfig.nvim',
  'https://github.com/neovim/nvim-lspconfig',

  -- Completado
  'https://github.com/saghen/blink.cmp',

  -- Utilidades varias
  'https://github.com/windwp/nvim-autopairs',
  'https://github.com/stevearc/oil.nvim',
  'https://github.com/akinsho/toggleterm.nvim',

  -- UI
  'https://github.com/stevearc/dressing.nvim',
  'https://github.com/echasnovski/mini.statusline',
  'https://github.com/echasnovski/mini.icons',

  -- Especificos de lenguaje
  'https://github.com/nvim-flutter/flutter-tools.nvim',
  'https://github.com/jinzhongjia/zig-lamp',
})

-- Plugins que requieren poca configuracion los pongo aca por ahora
require('oil').setup()
require('nvim-autopairs').setup()
require('toggleterm').setup()

-- Flutter Tools (lazy load por FileType)
vim.api.nvim_create_autocmd("FileType", {
  pattern = "dart",
  callback = function()
    require('flutter-tools').setup()
  end,
})

require('mini.icons').setup()
local statusline = require 'mini.statusline'
statusline.setup { use_icons = vim.g.have_nerd_font }
---@diagnostic disable-next-line: duplicate-set-field
statusline.section_location = function()
  return '%2l:%-2v'
end


require('plugins.lsp')
require('plugins.treesitter')
require('plugins.telescope')
require('plugins.autocompletion')

vim.cmd.colorscheme('vague')

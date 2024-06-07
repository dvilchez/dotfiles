" config
set title  " Muestra el nombre del archivo en la ventana de la terminal
set number  " Muestra los números de las líneas
set mouse=a  " Permite la integración del mouse (seleccionar texto, mover el cursor)

" set nowrap  " No dividir la línea si es muy larga

set cursorline  " Resalta la línea actual
set colorcolumn=120  " Muestra la columna límite a 120 caracteres

" Indentación a 2 espacios
set tabstop=2
set shiftwidth=2
set softtabstop=2
set shiftround
set expandtab  " Insertar espacios en lugar de <Tab>s

set hidden  " Permitir cambiar de buffers sin tener que guardarlos

set ignorecase  " Ignorar mayúsculas al hacer una búsqueda
set smartcase  " No ignorar mayúsculas si la palabra a buscar contiene mayúsculas

set spelllang=en,es  " Corregir palabras usando diccionarios en inglés y español

set termguicolors  " Activa true colors en la terminal
set background=light  " Fondo del tema: light o dark

set wrap

" Plugin
call plug#begin('~/.config/nvim/plugged')
  Plug 'numToStr/Comment.nvim'
  Plug 'dracula/vim'
  Plug 'ryanoasis/vim-devicons'
  Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
  Plug 'neovim/nvim-lspconfig'
  Plug 'hrsh7th/nvim-cmp'
  Plug 'hrsh7th/cmp-nvim-lsp'
  Plug 'L3MON4D3/LuaSnip'
  Plug 'williamboman/mason.nvim'
  Plug 'williamboman/mason-lspconfig.nvim'
  Plug 'VonHeikemen/lsp-zero.nvim', {'branch': 'v3.x'}
  Plug 'github/copilot.vim'
  Plug 'nvim-lua/plenary.nvim'
  Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.6' }
  Plug 'almo7aya/openingh.nvim',
  Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
" Initialize plugin system
call plug#end()

"lsp
lua <<EOF
local lsp_zero = require('lsp-zero')

lsp_zero.on_attach(function(client, bufnr)
  -- see :help lsp-zero-keybindings
  -- to learn the available actions
  lsp_zero.default_keymaps({buffer = bufnr,})
end)

local cmp = require('cmp')

cmp.setup({
  sources = {
    {name = 'nvim_lsp'},
  },
  mapping = {
    ['<CR>'] = cmp.mapping.confirm({select = true}),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<Up>'] = cmp.mapping.select_prev_item({behavior = 'select'}),
    ['<Down>'] = cmp.mapping.select_next_item({behavior = 'select'}),
    ['<C-p>'] = cmp.mapping(function()
      if cmp.visible() then
        cmp.select_prev_item({behavior = 'insert'})
      else
        cmp.complete()
      end
    end),
    ['<C-n>'] = cmp.mapping(function()
      if cmp.visible() then
        cmp.select_next_item({behavior = 'insert'})
      else
        cmp.complete()
      end
    end),
  },
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
})

require('lspconfig').sourcekit.setup({
cmd = { "sourcekit-lsp" , "--scratch-path", ".nativeBuild" },
	root_dir = function(filename)
		if string.match(filename, "Crossplatform") or string.match(filename, "CommonSwift") then
			return "/Users/david/wks/GoodNotes-5/Crossplatform"
		else
			return lspconfig.util.root_pattern("Package.swift")(filename)
		end
	end,
  single_file_support = false,
	on_attach = on_attach,
	capabilities = require('cmp_nvim_lsp').default_capabilities(),
  on_attach = lsp_zero.on_attach,
})

-- to learn how to use mason.nvim
-- read this: https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/guide/integrate-with-mason-nvim.md
require('mason').setup({})
require('mason-lspconfig').setup({
  ensure_installed = {},
  handlers = {
    function(server_name)
      require('lspconfig')[server_name].setup({})
    end,
  },
})

-- ripgrep to follow symlinks
local telescopeConfig = require("telescope.config")
local vimgrep_arguments = { unpack(telescopeConfig.values.vimgrep_arguments) }
table.insert(vimgrep_arguments, "-L")
require('telescope').setup{
	defaults = {
	  vimgrep_arguments = vimgrep_arguments,
		path_display = { "truncate" }
	},
	pickers = {
		find_files = {
			follow = true
		},
    buffers = {
      sort_lastused = true,
      ignore_current_buffer = true,
    }
	}
}
EOF

" theme
if (has("termguicolors"))
 set termguicolors
endif
syntax enable
colorscheme dracula

" search
nnoremap <C-p> <cmd>Telescope find_files<cr>
nnoremap <C-s> <cmd>Telescope buffers<cr>
nnoremap <C-l> <cmd>Telescope current_buffer_fuzzy_find<cr>

" copilot
imap <silent><script><expr> <C-J> copilot#Accept("\<CR>")
let g:copilot_no_tab_map = v:true


" config
set title  " Muestra el nombre del archivo en la ventana de la terminal
set number  " Muestra los números de las líneas
set mouse=a  " Permite la integración del mouse (seleccionar texto, mover el cursor)

set nowrap  " No dividir la línea si es muy larga

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

" Plugin
call plug#begin('~/.config/nvim/plugged')
  Plug 'tpope/vim-surround'
  Plug 'tpope/vim-commentary'
  Plug 'dracula/vim'
  Plug 'ryanoasis/vim-devicons'
  Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
  Plug 'junegunn/fzf.vim'
  Plug 'neoclide/coc.nvim', {'branch': 'release'}
  let g:coc_global_extensions = ['coc-emmet', 'coc-css', 'coc-html', 'coc-json', 'coc-prettier', 'coc-tsserver', 'coc-python'] 
  Plug 'leafgarland/typescript-vim'
  Plug 'peitalin/vim-jsx-typescript'
" Initialize plugin system
call plug#end()

" theme
if (has("termguicolors"))
 set termguicolors
endif
syntax enable
colorscheme dracula

" search
nnoremap <C-p> :Files<CR>
let g:fzf_action = {
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-s': 'split',
  \ 'ctrl-v': 'vsplit'
  \}
nnoremap <C-S-b> :Buffers<cr>
nnoremap <C-S-s> :BLines<cr>
let $FZF_DEFAULT_COMMAND = 'ag -g ""'

" resize pane
noremap Zz <c-w>_ \| <c-w>\|
noremap Zo <c-w>=

" coc
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gr <Plug>(coc-references)
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)
nmap <silent> <C-S-r> <Plug>(coc-codeaction)
nmap <silent> <C-S-m> <Plug>(coc-rename)
nnoremap <silent> <space>d :<C-u>CocList diagnostics<cr>

" git
map <F2> :!git shortlog -s -n %<cr>

" Prettier 
command! -nargs=0 Prettier :call CocAction('runCommand', 'prettier.formatFile')
nnoremap <silent> K :call CocAction('doHover')<CR>

" ----- general options -----
" disable vi compatability mode
:set nocompatible

" ----- display options -----
" always show the status bar so that the pretty powerline status bar is visible
set laststatus=2
" highlight searched terms
set hlsearch  
" turn off bracket matching
let loaded_matchparen = 1
" enable line numbers 
set number
" enable syntax highlighting, but allow :highlight commands to set colors,
" unlike syntax on
syntax enable
" enable solarized theme
set background=dark
colorscheme solarized
" enable fancy powerline symbols
set rtp+=$HOME/.local/lib/python2.7/site-packages/powerline/bindings/vim/
let g:powerline_pycmd = 'py3'
let g:Powerline_symbols = 'fancy'
" Use 256 colours 
set t_Co=256

" ----- performance options -----
" don't draw to the screen unless necessary (faster)
set lazyredraw
" improve performance when using a fast local terminal
set ttyfast

" ----- control options -----
" no more pesky escape key
imap jk <Esc>
set autoindent
" set the amount of spaces to shift when doing indentation
set shiftwidth=4
" set the amount of columns vim uses when tab is hit
set softtabstop=4
" make tab use spaces instead of the clearly inferior option of using tabs
set expandtab
" allow backspacing over autoindent, line breaks, and start of insert action
set backspace=indent,eol,start
set mouse=a

" ----- plugin options -----
" enable loading plugin files for filetypes
filetype plugin on
" infect your precious pure vim with nasty plugins
execute pathogen#infect()
" change path for vimwiki
let g:vimwiki_list = [{'path':'~/.vimwiki', 'path_html':'~/.vimwiki_html'}]


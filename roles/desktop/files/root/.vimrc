let g:airline_theme='sol'
let g:airline_skip_empty_sections = 1

syntax on
set number
set background=light
set tabstop=2 shiftwidth=2 expandtab smarttab autoindent
set showmatch
set hlsearch incsearch
set linebreak
set novisualbell noerrorbells
set laststatus=2
set scrolloff=4
set mouse=i
set backspace=indent,eol,start
set ttimeoutlen=10

if exists('+relativenumber')
  set relativenumber
  augroup numbertoggle
    autocmd!
    autocmd BufEnter,FocusGained,InsertLeave * set relativenumber
    autocmd BufLeave,FocusLost,InsertEnter   * set norelativenumber
  augroup END 
endif

if exists('+colorcolumn)
  set colorcolumn=80
  hi colorcolumn ctermbg=lightgrey guibg=lightgrey
endif

if exists('term')
  set term=screen-256color
endif
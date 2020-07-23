let g:airline_theme='sol'
let g:airline_skip_empty_sections = 1

syntax on

set tabstop=2 shiftwidth=2 expandtab smarttab autoindent
set showmatch
set linebreak
set novisualbell noerrorbells
set mouse=i
set backspace=indent,eol,start
set ttimeoutlen=10
set laststatus=2
set scrolloff=4

set term=screen-256color
set background=light

set hlsearch incsearch
hi Search ctermbg=DarkBlue ctermfg=White
nnoremap <silent> <Space> :nohlsearch<Bar>:echo<CR>

set colorcolumn=80,100
hi colorcolumn ctermbg=lightgrey guibg=lightgrey

" use hybrid line numbering by default with automatic toggling
set number relativenumber
augroup numbertoggle
  autocmd!
  autocmd BufEnter,FocusGained,InsertLeave * set relativenumber
  autocmd BufLeave,FocusLost,InsertEnter   * set norelativenumber
augroup END

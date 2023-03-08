set number
set relativenumber
set shortmess+=I
set ignorecase
set smartcase
let &tabstop=4
set expandtab
set nowrap
set noswapfile

inoremap <C-c> <ESC>

autocmd FileType json,markdown,html let &tabstop=2
autocmd FileType * let &shiftwidth=&tabstop
autocmd VimEnter * silent! NoMatchParen

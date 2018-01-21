
" install vimplug https://github.com/junegunn/vim-plug#installation
call plug#begin('~/.vim/plugged') 



" utility
"Plug 'vim-airline/vim-airline'
Plug 'kien/ctrlp.vim'
Plug 'vim-scripts/Colour-Sampler-Pack'
Plug 'scrooloose/nerdtree'
Plug 'scrooloose/nerdcommenter'
"Plug 'mbbill/undotree'
"Plug 'mileszs/ack.vim'
Plug 'majutsushi/tagbar'
Plug 'tpope/vim-fugitive' 
"Plug 'mbbill/undotree'
Plug 'w0rp/ale'
"Plug 'Valloric/YouCompleteMe' 


" editing
"Plug 'alvan/vim-closetag'
Plug 'ervandew/supertab' 
Plug 'Raimondi/delimitMate'

" language
Plug 'rodjek/vim-puppet'
Plug 'vim-ruby/vim-ruby'
Plug 'tmux-plugins/vim-tmux'
Plug 'martinda/Jenkinsfile-vim-syntax'
Plug 'elixir-editors/vim-elixir'
Plug 'leafgarland/typescript-vim'
Plug 'vim-scripts/nginx.vim'
Plug 'mustache/vim-mustache-handlebars'


call plug#end() 

" turn off old school vim mode, should be first b/c it overwites some defaults 
set nocompatible

" turn off wrap by defaults  
set nowrap 



"closetag commands 
"autocmd FileType html,htmldjango,jinjahtml,eruby,mako let b:closetag_html_style=1
"autocmd FileType html,xhtml,xml,htmldjango,jinjahtml,eruby,mako source ~/.vim/bundle/closetag/plugin/closetag.vim


"solarized
set background=dark
"Tomorrow-Night-Bright  summerfruit256 solarized native molokai herald darkz adrian no_quarter railscasts
colorscheme herald
if has("gui_running")
  if has("gui_gtk2")
    set guifont=Inconsolata\ 12
  elseif has("gui_macvim")
    set guifont=Menlo\ Regular:h18
  elseif has("gui_win32")
    set guifont=Consolas:h11:cANSI
  endif
endif
"always try to show syntax 
syntax on 

"http://stackoverflow.com/questions/677986/vim-copy-selection-to-os-x-clipboard
set clipboard=unnamed


" status information
set laststatus=2
:hi User1 term=inverse,bold cterm=inverse,bold ctermfg=red
set ruler "show the cursor position all the time "
set showcmd

" highlight current line 
set cursorline
set cursorcolumn
highlight CursorLine   cterm=NONE ctermbg=91 ctermfg=NONE guibg=DarkBlue guifg=NONE
highlight CursorColumn   cterm=NONE ctermbg=91 ctermfg=NONE guibg=DarkBlue guifg=NONE


set cmdheight=1



" Don't show scroll bars in the GUI
set guioptions-=L
set guioptions-=r

" Store temporary files in a central spot
set backupdir=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp
set directory=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp

" needed for running vim with zsh
set shell=/bin/sh



" add mouse scrolling to command line vim http://stackoverflow.com/questions/7225057/use-mouse-scroll-wheel-in-vim
set mouse=a
map <ScrollWheelUp> <C-Y>
map <ScrollWheelDown> <C-E>




"remove the tool bar 
set go-=T

" turn off mode lines b/c i don't use them for security reasons
set modelines=0

" document format
set encoding=utf-8

" turn on spelling
"set spell

" cool tab completion stuff
set wildmenu
set wildmode=list:longest,full

"remp jj to escape insert mode
inoremap jj <Esc>


" tab settings 
set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab


" turn on auto indent
set autoindent
set showmode


"turn off annoing bells
set noerrorbells
set visualbell

set showmatch " show matching brackes
set showcmd "show partial command in status line


"turn outo save on 
"au FocusLost * :wa

" reload the vim file 
"if has("autocmd")
  "autocmd bufwritepost .vimrc source $MYVIMRC
"endif 
"make it easier to edit vim

"map the ; to the : key
nore ; :

"change the leacer key
let mapleader = ","

"taming search 
nnoremap / /\v
vnoremap / /\v
set ignorecase
set smartcase
set incsearch
set hlsearch
nnoremap <leader><space> :noh<cr>
nnoremap <leader><CR> :%s/\r/\r/g<cr>

set number


"show invisiable chars 
"set list 
"set listchars=tab:▸\ ,eol:¬

"easy buffer naivation 
noremap <C-h>  <C-w>h
noremap <C-j>  <C-w>j
noremap <C-k>  <C-w>k
noremap <C-l>  <C-w>l




"easy folding 
noremap <space> za
vnoremap <space> zf

"rails commands 
"nnoremap <leader>m :Rmodel<cr>
"nnoremap <leader>c :Rcontroller<cr>
"nnoremap <leader>h :Rview<cr>
"nnoremap <leader>ra :AV<cr>
"nnoremap <leader>av :AV<cr>

" open markdown file in marked.app 
"  http://captainbollocks.tumblr.com/post/9858989188/linking-macvim-and-marked-app
nnoremap <leader>m <Esc>:silent !open -a Marked.app '%:p'<CR>



"rspec commands
nnoremap <leader>r :!rspec %<cr>
vnoremap <leader>r :!rspec %<cr>

"rspec commands
nnoremap <leader>c :!clear && make %:r && ./%:r<cr>
vnoremap <leader>c :!clear && make %:r && ./%:r<cr>

nnoremap <leader>v :!clear && make %:r && valgrind ./%:r<cr>
vnoremap <leader>v :!clear && make %:r && valgrind ./%:r<cr>

" TRAINING KEYS REMOVED
inoremap <up>    :resize +10 <cr>
inoremap <down>  :resize -10 <cr>
inoremap <left>  :vertical resize -10 <cr>
inoremap <right> :vertical resize +10 <cr>

vnoremap <up>    :resize +10 <cr>
vnoremap <down>  :resize -10 <cr>
vnoremap <left>  :vertical resize -10 <cr>
vnoremap <right> :vertical resize +10 <cr>

nnoremap <up>    :resize +10 <cr>
nnoremap <down>  :resize -10 <cr>
nnoremap <left>  :vertical resize -10 <cr>
nnoremap <right> :vertical resize +10 <cr>



inoremap <F1> <ESC>
nnoremap <F1> <ESC>
vnoremap <F1> <ESC>

nnoremap <leader>0 :tabnext<cr> 
nnoremap <leader>9 :tabprevious<cr> 
nnoremap <C-t> :tabnew<cr> 

" powerline

" ale
let g:ale_set_highlights = 0
let g:ale_completion_enabled = 1
let g:ale_fixers = {
      \  'typescript': ['tslint']
      \}
let g:ale_fix_on_save = 1


" control p 
set runtimepath^=~/.vim/bundle/ctrlp.vim
let g:ctrlp_map = '<leader>o'
noremap <leader>p <Esc>:CtrlPBuffer<CR>
let g:ctrlp_cmd = 'CtrlP'
let g:ctrlp_match_window_reversed = 0
let g:ctrlp_max_height = 90
let g:ctrlp_custom_ignore = 'node_modules\|bower_components\|_build\|deps\|DS_Store\|git\|blockbuster'


noremap <leader>t <Esc>:!mate %:p<CR>

"for Syntastic
let g:syntastic_enable_signs=1
let g:syntastic_check_on_open=1

"for tagbar
:nnoremap <leader>i <Esc>:TagbarOpenAutoClose<CR>
let g:tagbar_left = 1
let g:tagbar_sort = 0

"vim rspec conque
" Cmd-Shift-R for RSpec
nmap <silent> <D-R> :call RunRspecCurrentFileConque()<CR>
" Cmd-Shift-L for RSpec Current Line
nmap <silent> <D-L> :call RunRspecCurrentLineConque()<CR>

"nerd tree
"nnoremap <leader>o :NERDTreeToggle<cr>

"undotree
nnoremap <F5> :UndotreeToggle<cr>

"remove trailing whitespace 
" match Todo /\s\+$/
:nnoremap <leader>w :%s/\s\+$//e<cr>

"autocmd BufRead,BufNewFile *.hbhaml setf haml

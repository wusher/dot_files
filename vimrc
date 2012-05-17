"pathogen commands 
call pathogen#runtime_append_all_bundles()
call pathogen#helptags()

" turn off old school vim mode, should be first b/c it overwites some defaults 
set nocompatible


" turn off wrap by defaults  
set nowrap 


"closetag commands 
autocmd FileType html,htmldjango,jinjahtml,eruby,mako let b:closetag_html_style=1
autocmd FileType html,xhtml,xml,htmldjango,jinjahtml,eruby,mako source ~/.vim/bundle/closetag/plugin/closetag.vim

set gfn=Monaco:h12


"nerdcommenter commands 
"[count]<leader>ci
"[count]<leader>cy
"<leader>c$
"<leader>cA

"supertab commands
"let g:SuperTabDefaultCompletionType = "context"

"solarized
set background=dark
"let g:solarized_termtrans=1
"let g:solarized_termcolors=256
"let g:solarized_contrast="high"
"let g:solarized_visibility="high"
"zed's: moria, kib_darktango, native, ps_color, pyte, zenburn 
colorscheme Tomorrow-Night-Bright "summerfruit256 solarized native molokai herald darkz adrian no_quarter railscasts

"always try to show syntax 
syntax on 



" status informationr 
set laststatus=2
set statusline=%<%f%=\ [%1*%M%*%n%R]\ y\ %-19(%3l,%02c%03V%)
" old set statusline=%<%f\ (%{&ft})\ %-4(%m%)%=%-19(%3l,%02c%03V%)
:hi User1 term=inverse,bold cterm=inverse,bold ctermfg=red
set ruler "show the cursor position all the time "
set showcmd

" highlight current line 
set cursorline
set cmdheight=1


" Don't show scroll bars in the GUI
set guioptions-=L
set guioptions-=r

" Store temporary files in a central spot
set backupdir=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp
set directory=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp




"remove the tool bar 
set go-=T

" turn off mode lines b/c i don't use them for security reasons
set modelines=0

" document format
set encoding=utf-8

" cool tab completion stuff
set wildmenu
set wildmode=list:longest,full

"remp jj to escape insert mode
inoremap jj <Esc>

" hightligh the search results
" set hlsearch

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
au FocusLost * :wa

" reload the vim file 
if has("autocmd")
  autocmd bufwritepost .vimrc source $MYVIMRC
endif 
"make it easier to edit vim
nmap <leader>v :tabedit $MYVIMRC<CR>
nnoremap <leader>o :NERDTreeToggle<cr>

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
nnoremap <leader>m :Rmodel<cr>
nnoremap <leader>c :Rcontroller<cr>
nnoremap <leader>h :Rview<cr>
nnoremap <leader>a  :A<cr>
nnoremap <leader>r  :R<cr>
nnoremap <leader>av :AV<cr>
nnoremap <leader>rv :RV<cr>
nnoremap <leader>as :AS<cr>
nnoremap <leader>rs :RS<cr>


" TRAINING KEYS REMOVED
"nnoremap <up> <nop>
"nnoremap <down> <nop>
"nnoremap <left> <nop>
"nnoremap <right> <nop>
"inoremap <up> <nop>
"inoremap <down> <nop>
"inoremap <left> <nop>
"inoremap <right> <nop>

inoremap <F1> <ESC>
nnoremap <F1> <ESC>
vnoremap <F1> <ESC>

nnoremap <leader>0 :tabnext<cr> 
nnoremap <leader>9 :tabprevious<cr> 
nnoremap <C-t> :tabnew<cr> 



" bindings for the rim refractor plugin 

:nnoremap <leader>rap  :RAddParameter<cr>
:nnoremap <leader>rcpc :RConvertPostConditional<cr>
:nnoremap <leader>rel  :RExtractLet<cr>
:vnoremap <leader>rec  :RExtractConstant<cr>
:vnoremap <leader>relv :RExtractLocalVariable<cr>
:nnoremap <leader>rit  :RInlineTemp<cr>
:vnoremap <leader>rrlv :RRenameLocalVariable<cr>
:vnoremap <leader>rriv :RRenameInstanceVariable<cr>
:vnoremap <leader>rem  :RExtractMethod<cr>


" command T
noremap <leader>o <Esc>:CommandT<CR>
noremap <leader>i <Esc>:CommandTBuffer<CR>
noremap <leader>m <Esc>:CommandTFlush<CR>



noremap <leader>t <Esc>:!mate %:p<CR>


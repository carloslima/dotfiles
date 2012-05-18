version 7.0

""" Vundle Entries
" NOTE: comments after Bundle command are not allowed..
set nocompatible               " be iMproved
filetype off                   " required!

set runtimepath+=~/.vim/bundle/vundle/
call vundle#rc()

" let Vundle manage Vundle
" required! 
Bundle 'gmarik/vundle'

" My Bundles here:
"
" original repos on github
Bundle 'tpope/vim-fugitive'
Bundle 'c9s/perlomni.vim'
Bundle 'kien/ctrlp.vim'
  map <Leader>t :CtrlPBuffer<CR>
  let g:ctrlp_map = '<C-t>'
  let g:ctrlp_working_path_mode = 0 " don’t manage working directory.
  let g:ctrlp_custom_ignore = {
  \ 'dir':  '\v\c\.(git|svn)$|cgi/t/sandbox|cover_db',
  \ 'file': '\v\c\.(swf|bak|png|gif|js|mov|ico|jpg|pdf|jrxml)$',
  \ }
Bundle 'Lokaltog/vim-powerline'
  let g:Powerline_symbols = 'fancy'
Bundle 'Lokaltog/vim-easymotion'

" vim-scripts repos
"Bundle 'L9'
"Bundle 'FuzzyFinder'
"  let g:fuf_coveragefile_exclude = '\c\.\(swf\|bak\|png\|gif\|js\|mov\|ico\|jpg\|pdf\|jrxml\)$\|cgi\/t\/sandbox\|\/cover_db\/'
"  map <Leader>t :FufBuffer<CR>
"  map <C-t> :FufCoverageFile<CR>

" non github repos
"Bundle 'git://git.wincent.com/command-t.git'
" ...

filetype plugin indent on     " required!

""" vimrc resumes :-)

set autoindent
set backspace=indent,eol,start
set cindent " set smartindent
set cmdheight=2
set cursorcolumn
set cursorline
set errorformat=\"../../%f\"\\,%*[^0-9]%l:\ %m
set expandtab
set hidden
set hlsearch
set ignorecase
set incsearch
set laststatus=2
set list
set listchars=tab:>-,trail:-
set mouse=c
set nowrap
set number
set ruler
set scrolloff=5
set shiftwidth=4
set showcmd
set showmatch
set smarttab
"set statusline=%F%m%r%h%w\ [%{&ff}]\ %y\ [CHR=%b/0x%B]\ [POS=%04l,%03c(%03v)]\ [%p%%]\ [LEN=%L]\ %{fugitive#statusline()}
set t_Co=256
set tags=tags;/
set virtualedit=block
set wrap
syntax on

highlight   CursorColumn  term=NONE    cterm=none ctermbg=232
highlight   CursorLine    term=NONE    cterm=bold ctermbg=8
highlight   FoldColumn                            ctermbg=8  ctermfg=14
highlight   Folded                                ctermbg=8  ctermfg=14
highlight   Search        term=reverse cterm=bold ctermbg=11 ctermfg=0
highlight   Visual        term=NONE    cterm=bold ctermbg=10 ctermfg=8
"
"" makes Omni Completion less pinky :P
highlight   Pmenu                                 ctermbg=2  ctermfg=0
highlight   PmenuSel                              ctermbg=7  ctermfg=0
highlight   PmenuSbar                             ctermbg=0  ctermfg=7
highlight   PmenuThumb                            ctermbg=7  ctermfg=0


" Enable syntax highlight for *.tt as html
autocmd BufRead,BufNewFile *.tt set filetype=html

" :help last-position-jump
autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif

nnoremap <C-L> :noh<CR><C-L>
inoremap jj <Esc>
nnoremap <Leader>r :source ~/.vimrc<CR>
nnoremap <Leader><Leader>r :e ~/.vimrc<CR>

map <Leader>gs :Gstatus<CR>
map <Leader>gc :Gcommit<CR>
map <Leader>gm :Gcommit --amend<CR>
map <Leader>gll :Git log<CR>
map <Leader>glp :Git log -p<CR>
map <Leader>gb :Gblame<CR>
map <Leader>gdd :Git diff<CR>
map <Leader>gdm :Git diff %<CR>
map <Leader>gdf :Gdiff<CR>
map <Leader>gg :Git 

nmap <F1> <Esc>
imap <F1> <Esc>

autocmd BufRead,BufNewFile *.t,*.pl,*.pm,*.cgi,*.PL set equalprg=perltidy
autocmd BufRead,BufNewFile *.t,*.pl,*.pm,*.cgi,*.PL map <Leader>ur :!su nobody -c "perl  -I/home/git/bom/cgi %"<CR>
autocmd BufRead,BufNewFile *.t,*.pl,*.pm,*.cgi,*.PL map <Leader>up :!prove -I/home/git/bom/cgi %<CR>
autocmd BufRead,BufNewFile *.t,*.pl,*.pm,*.cgi,*.PL map <Leader>ud :!perl  -I/home/git/bom/cgi -d %<CR>
autocmd BufRead,BufNewFile *.t,*.pl,*.pm,*.cgi,*.PL map <Leader>us :!perl /home/git/bom/cgi/t/run_all.pl %<CR>
autocmd BufRead,BufNewFile *.t,*.pl,*.pm,*.cgi,*.PL map <Leader>uf :!prove /home/git/bom/cgi/t/run_all.pl :: --fast<CR>
autocmd BufRead,BufNewFile *.t,*.pl,*.pm,*.cgi,*.PL map <Leader>uc :!perl -I/home/git/bom/cgi -I/home/git/bom/t -c %<CR>
autocmd BufRead,BufNewFile *.t,*.pl,*.pm,*.cgi,*.PL map <Leader>uC :!perlcritic %<CR>

nnoremap <Leader>] :!perl -Ilib %<CR>
nnoremap <Leader><Leader>] :!perl -d -Ilib %<CR>

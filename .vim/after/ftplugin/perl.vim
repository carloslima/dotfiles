set shiftwidth=4
set equalprg=perltidy
map <Leader>uC :!perlcritic %<CR>

" too-environment-especific and wrong. pretend you didn't see this.
map <Leader>ur :!su nobody -c "perl  -I/home/git/bom/cgi %"<CR>
map <Leader>up :!prove -I/home/git/bom/cgi %<CR>
map <Leader>ud :!perl  -I/home/git/bom/cgi -d %<CR>
map <Leader>us :!perl /home/git/bom/cgi/t/run_all.pl %<CR>
map <Leader>uf :!prove /home/git/bom/cgi/t/run_all.pl :: --fast<CR>
map <Leader>uc :!perl -I/home/git/bom/cgi -I/home/git/bom/t -c %<CR>

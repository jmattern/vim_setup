set nocompatible
let mapleader = ','
let s:config_root = fnamemodify(expand('<sfile>:p'), ':h') . '/.vim'
let s:after_root = s:config_root . '/after'
if index(split(&runtimepath, ','), s:config_root) < 0
    execute 'set runtimepath^=' . fnameescape(s:config_root)
endif
if index(split(&runtimepath, ','), s:after_root) < 0
    execute 'set runtimepath+=' . fnameescape(s:after_root)
endif

" Load plugins only when Vundle is installed.
if filereadable(s:config_root . '/plugins.vim')
    execute 'source ' . fnameescape(s:config_root . '/plugins.vim')
endif

syntax on
filetype plugin indent on

let g:gruvbox_contrast_dark = 'hard'
if !empty(globpath(&runtimepath, 'colors/gruvbox.vim'))
    colorscheme gruvbox
endif
set background=dark

" Keep Vim's native ., s, and ; motions. Plugin commands use the leader.
nnoremap <leader>f :Files<CR>
nnoremap <leader>a :Ag<Space>
nnoremap <leader>n :NERDTreeToggle<CR>
nnoremap <C-_> :NERDTreeFind<CR>
nnoremap <C-h> :resize +1<CR>
nnoremap <C-j> :resize -1<CR>
nnoremap <C-k> :vertical resize +1<CR>
nnoremap <C-l> :vertical resize -1<CR>

let g:NERDDefaultAlign = 'left'
let NERDTreeIgnore = ['\.pyc$']

augroup vim_setup_quickfix
    autocmd!
    autocmd QuickFixCmdPost *grep* cwindow
augroup END


set number
if &statusline !~# '%F'
    set statusline+=%F
endif
set colorcolumn=180
set nowrap
set mouse=a
set hlsearch
set updatetime=100

if exists('python_highlight_all') | unlet python_highlight_all | endif
if exists('python_space_error_highlight') | unlet python_space_error_highlight | endif

if v:version >= 800
    let g:ale_enabled = 1
    let g:ale_linters = {'python': ['flake8']}
    let g:ale_fixers = {'python': ['autopep8']}
endif

" Preserve the convenient Ag wrapper when fzf.vim is available.
command! -bang -nargs=* Ag call fzf#vim#ag(<q-args>, {'options': '--delimiter : --nth 4..'}, <bang>0)

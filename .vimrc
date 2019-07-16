filetype off
so ~/.vim/plugins.vim
syntax on
filetype plugin indent on

"Choose Color Scheme

"colorscheme sublimemonokai
let g:gruvbox_contrast_dark = 'hard'
colorscheme gruvbox
set bg=dark

"If using Signify instead of gitgutter
"let g:signify_vcs_list = ['git']
"let g:signify_realtime = 1
"let g:signify_update_on_bufenter = 1
"let g:signify_update_on_focusgained = 1

if v:version > 800
	"Use Ale if vim version is 8.0 or above
	let g:ale_enabled = 1
	let g:ale_linters = {'python': ['flake8', 'sandboxpylint']}
	let g:ale_fixers = ['autopep8']
else
	"Otherwise use Autopep8
	autocmd FileType python noremap <F8> :call Autopep8()<CR>
endif

"Comment Flush with Left
let g:NERDDefaultAlign = 'left'

"Custom Mappings
map ; :Files<CR>
map s :Ag 
map . :NERDTreeToggle<CR>
map <C-_> :NERDTreeFind<CR>
map <C-h> :resize +1<CR>
map <C-j> :resize -1<CR>
map <C-k> :vertical resize +1<CR>
map <C-l> :vertical resize -1<CR>
let mapleader = ","
map \ ,c 
map <F9> :call ToggleDocTestMode()<CR>

"F5 mapping to run python scripts
autocmd BufRead *.py nmap <F5> :!python %<CR>

"Editor Configurations
"set nocompatible
set number
set statusline+=%F
set colorcolumn=180
set nowrap
set mouse=a
set hlsearch
set updatetime=100
let NERDTreeIgnore = ['\.pyc$']

"Turn off whitespace highlighting for python
if exists('python_highlight_all')
    unlet python_highlight_all
endif
if exists('python_space_error_highlight')
    unlet python_space_error_highlight
endif

"only shows file contents in Ag instead of file names
command! -bang -nargs=* Ag call fzf#vim#ag(<q-args>, {'options': '--delimiter : --nth 4..'}, <bang>0)

so ~/.vim/plugins.vim
syntax on

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

"Editor Configurations
set number
set statusline+=%F
set colorcolumn=180
set nowrap
set mouse=a
set hlsearch
set updatetime=100
let NERDTreeIgnore = ['\.pyc$']

"only shows file contents in Ag instead of file names
command! -bang -nargs=* Ag call fzf#vim#ag(<q-args>, {'options': '--delimiter : --nth 4..'}, <bang>0)

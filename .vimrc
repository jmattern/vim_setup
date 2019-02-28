so ~/.vim/plugins.vim
syntax on
"colorscheme sublimemonokai
let g:gruvbox_contrast_dark = 'hard'
let g:signify_vcs_list = ['git']
let g:signify_realtime = 1
let g:signify_update_on_bufenter = 1
let g:signify_update_on_focusgained = 1
colorscheme gruvbox
set bg=dark
map ; :Files<CR>
map s :Ag 
map . :NERDTreeToggle<CR>
map <C-_> :NERDTreeFind<CR>

map <C-h> :resize +1<CR>
map <C-j> :resize -1<CR>
map <C-k> :vertical resize +1<CR>
map <C-l> :vertical resize -1<CR>
set number
set statusline+=%F
set colorcolumn=180
set nowrap
set mouse=a
set hlsearch
let NERDTreeIgnore = ['\.pyc$']
let mapleader = ","
map \ ,c 
autocmd FileType python noremap <F8> :call Autopep8()<CR>

"only shows file contents in Ag instead of file names
command! -bang -nargs=* Ag call fzf#vim#ag(<q-args>, {'options': '--delimiter : --nth 4..'}, <bang>0)
"only shows file contents in Ag instead of file names
"let FZF_DEFAULT_COMMAND='fd --type f'
"let FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
"fzf
"export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

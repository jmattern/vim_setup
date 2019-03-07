set rtp+=~/.vim/bundle/Vundle.vim

call vundle#begin()

Plugin 'VundleVim/Vundle.vim'
Plugin 'editorconfig/editorconfig-vim'
Plugin 'itchyny/lightline.vim'
Plugin 'junegunn/fzf'
Plugin 'junegunn/fzf.vim'
Plugin 'mattn/emmet-vim'
Plugin 'scrooloose/nerdtree'
Plugin 'terryma/vim-multiple-cursors'
Plugin 'tpope/vim-eunuch'
Plugin 'tpope/vim-surround'
Plugin 'ErichDonGubler/vim-sublime-monokai'
Plugin 'Valloric/YouCompleteMe'
Plugin 'morhetz/gruvbox'
Plugin 'sheerun/vim-polyglot'
Plugin 'scrooloose/nerdcommenter'
Plugin 'tpope/vim-fugitive'

"Choose signify or gitgutter
Plugin 'airblade/vim-gitgutter'
"Plugin 'mhinz/vim-signify'

if v:version >= 800
	Plugin 'w0rp/ale'
else
	Plugin 'nvie/vim-flake8'
	Plugin 'tell-k/vim-autopep8'
endif

call vundle#end()

filetype plugin indent on

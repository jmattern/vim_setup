let s:vundle = fnamemodify(expand('<sfile>:p'), ':h') . '/bundle/Vundle.vim'
if !isdirectory(s:vundle)
    finish
endif
execute 'set runtimepath^=' . fnameescape(s:vundle)
if !filereadable(s:vundle . '/autoload/vundle.vim')
    finish
endif

call vundle#begin(fnamemodify(s:vundle, ':h'))
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
Plugin 'airblade/vim-gitgutter'

if v:version >= 800
    Plugin 'dense-analysis/ale'
else
    Plugin 'nvie/vim-flake8'
    Plugin 'tell-k/vim-autopep8'
endif

call vundle#end()
filetype plugin indent on

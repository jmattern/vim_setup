#!/bin/bash

cd ..
scp -r .vim ~/.vim
scp .vimrc ~/.vimrc
scp .tmux.conf ~/.tmux.conf
scp pylint_variations/sandbox_pylint.vim ~/.vim/
scp pylint_variations/doclint.vim ~/.vim/

pip install --upgrade setuptools
pip install flake8
pip install pylint
sudo apt-get install vim-gtk

cd ~/.vim
sudo ./update_vim
./download_plugins
scp sandbox_pylint.vim bundle/ale/ale_linters/python/pylint.vim
scp doclint.vim bundle/ale/ale_linters/python/doclint.vim
rm sandbox_pylint.vim
rm doclint.vim

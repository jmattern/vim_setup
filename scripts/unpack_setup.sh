#!/bin/bash

cd ..
scp -r .vim ~/.vim
scp .vimrc ~/.vimrc
scp pylint_variations/sandbox_pylint.vim ~/.vim/

pip install --upgrade setuptools
pip install flake8
pip install pylint
sudo apt-get install vim-gtk

cd ~/.vim
sudo ./update_vim
./download_plugins
scp sandbox_pylint.vim bundle/ale/ale_linters/python/pylint.vim

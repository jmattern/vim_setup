#!/bin/bash

# Move files around
cd ..
scp -r .vim ~/.vim
scp .vimrc ~/.vimrc
scp .tmux.conf ~/.tmux.conf
# scp pylint_variations/sandboxpylint.vim ~/.vim/
# scp pylint_variations/doclint.vim ~/.vim/
scp .config/flake8 ~/.config/

# Install dependencies
pip install --upgrade setuptools
pip install flake8
pip install pylint
sudo apt-get install vim-gtk
sudo apt install exuberant-ctags
sudo apt install sshpass

# Run Install scripts
cd ~/.vim
sudo ./update_vim
./download_plugins

# Load linters
# scp sandboxpylint.vim bundle/ale/ale_linters/python/sandboxpylint.vim
# scp doclint.vim bundle/ale/ale_linters/python/doclint.vim
# rm sandboxpylint.vim
# rm doclint.vim

# Compile YouCompleteMe
# install gcc 8 to compile
sudo apt-get install g++-8
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-7 700 --slave /usr/bin/g++ g++ /usr/bin/g++-7
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-8 800 --slave /usr/bin/g++ g++ /usr/bin/g++-8
sudo pip install --upgrade cryptography  # May have to do this 
sudo apt install build-essential cmake python3-dev
cd ~/.vim/bundle/YouCompleteMe
python install.py --clang-completer

# Make vim default editor
sudo update-alternatives --install /usr/bin/editor editor /usr/local/bin/vim 1
sudo update-alternatives --set editor /usr/local/bin/vim
sudo update-alternatives --install /usr/bin/vi vi /usr/local/bin/vim 1
sudo update-alternatives --set vi /usr/local/bin/vim

#!/bin/bash

# Move files around
cd ..
scp -r .vim ~/.
scp .vimrc ~/.
scp .tmux.conf ~/.
# scp pylint_variations/sandboxpylint.vim ~/.vim/
# scp pylint_variations/doclint.vim ~/.vim/
scp -r .config ~/.

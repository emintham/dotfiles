#!/bin/bash
#

cp gitconfig ~/.gitconfig
cp aliases.zsh ~/aliases.zsh
echo 'source $HOME/aliases' >> ~/.bashrc
echo 'source $HOME/aliases' >> ~/.zshrc

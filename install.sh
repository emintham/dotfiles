#!/bin/bash
#

ln -s gitconfig ~/.gitconfig
ln -s aliases ~/aliases
ln -s ripgreprc ~/.ripgreprc

echo 'source $HOME/aliases' >> ~/.bashrc
echo 'source $HOME/aliases' >> ~/.zshrc

#!/bin/bash
#

cp gitconfig ~/.gitconfig
cp aliases ~/aliases
cat "source $HOME/aliases" >> ~/.bashrc

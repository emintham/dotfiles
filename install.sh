#!/bin/bash
#

# Get the absolute path of the directory where this script is located.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Create symlinks using absolute paths.
# The -f flag ensures that existing symlinks are overwritten.
ln -sf "$SCRIPT_DIR/gitconfig" ~/.gitconfig
ln -sf "$SCRIPT_DIR/aliases.sh" ~/aliases.sh
ln -sf "$SCRIPT_DIR/ripgreprc" ~/.ripgreprc

echo 'source $HOME/aliases.sh' >> ~/.bashrc
echo 'source $HOME/aliases.sh' >> ~/.zshrc

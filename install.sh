#!/bin/bash
#
set -e  # Exit on error

# Get the absolute path of the directory where this script is located.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Backup directory
BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"

# Function to backup a file if it exists
backup_file() {
  local file="$1"
  if [ -e "$file" ]; then
    mkdir -p "$BACKUP_DIR"
    echo "Backing up $file to $BACKUP_DIR"
    cp -P "$file" "$BACKUP_DIR/" || {
      echo "Warning: Failed to backup $file"
      return 1
    }
  fi
}

# Backup existing files before creating symlinks
backup_file ~/.gitconfig
backup_file ~/aliases.sh
backup_file ~/.ripgreprc

# Create symlinks using absolute paths.
# The -f flag ensures that existing symlinks are overwritten.
echo "Creating symlinks..."
ln -sf "$SCRIPT_DIR/gitconfig" ~/.gitconfig
ln -sf "$SCRIPT_DIR/aliases.sh" ~/aliases.sh
ln -sf "$SCRIPT_DIR/ripgreprc" ~/.ripgreprc
ln -sf "$SCRIPT_DIR/.gitignore" ~/.gitignore
ln -sf "$SCRIPT_DIR/.gitattributes" ~/.gitattributes

# Function to add source line to shell rc file if not already present
add_to_rc() {
  local rc_file="$1"
  local source_line='source $HOME/aliases.sh'

  if [ -f "$rc_file" ]; then
    if ! grep -qF "$source_line" "$rc_file"; then
      echo "Adding source line to $rc_file"
      echo "$source_line" >> "$rc_file"
    else
      echo "Source line already present in $rc_file"
    fi
  else
    echo "Creating $rc_file and adding source line"
    echo "$source_line" > "$rc_file"
  fi
}

# Add source line to shell rc files
add_to_rc ~/.bashrc
add_to_rc ~/.zshrc

echo "Installation complete!"
if [ -d "$BACKUP_DIR" ]; then
  echo "Backups saved to: $BACKUP_DIR"
fi

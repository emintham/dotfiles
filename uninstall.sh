#!/bin/bash
#
# Uninstall script for dotfiles
# Removes symlinks and source lines from shell rc files

set -e  # Exit on error

echo "Uninstalling dotfiles..."

# Function to remove a symlink if it exists and points to our dotfiles
remove_symlink() {
  local link="$1"
  if [ -L "$link" ]; then
    echo "Removing symlink: $link"
    rm "$link"
  elif [ -e "$link" ]; then
    echo "Warning: $link exists but is not a symlink. Skipping."
  else
    echo "Symlink $link does not exist. Skipping."
  fi
}

# Remove symlinks
remove_symlink ~/.gitconfig
remove_symlink ~/aliases.sh
remove_symlink ~/.ripgreprc
remove_symlink ~/.gitignore
remove_symlink ~/.gitattributes

# Function to remove source line from shell rc file
remove_from_rc() {
  local rc_file="$1"
  local source_line='source $HOME/aliases.sh'

  if [ -f "$rc_file" ]; then
    if grep -qF "$source_line" "$rc_file"; then
      echo "Removing source line from $rc_file"
      # Create a backup before modifying
      cp "$rc_file" "${rc_file}.bak"
      # Remove the line using grep -v (inverse match)
      grep -vF "$source_line" "$rc_file" > "${rc_file}.tmp"
      mv "${rc_file}.tmp" "$rc_file"
      echo "Backup saved to ${rc_file}.bak"
    else
      echo "Source line not found in $rc_file"
    fi
  else
    echo "$rc_file does not exist. Skipping."
  fi
}

# Remove source line from shell rc files
remove_from_rc ~/.bashrc
remove_from_rc ~/.zshrc

echo ""
echo "Uninstall complete!"
echo "Your dotfiles symlinks have been removed."
echo "Backup files were created for any modified shell rc files (*.bak)"
echo ""
echo "Note: To restore your previous configuration, check ~/.dotfiles_backup/"

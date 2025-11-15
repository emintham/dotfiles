#!/bin/bash
#
# Validation script for dotfiles
# Runs shellcheck on all shell scripts

# Check if shellcheck is installed
if ! command -v shellcheck &> /dev/null; then
  echo "Error: shellcheck is not installed."
  echo "Please install shellcheck to validate shell scripts:"
  echo "  - Ubuntu/Debian: sudo apt-get install shellcheck"
  echo "  - macOS: brew install shellcheck"
  echo "  - Or visit: https://github.com/koalaman/shellcheck"
  exit 1
fi

echo "Running shellcheck on all shell scripts..."
echo ""

# Track if any errors were found
errors_found=0

# Function to check a shell script
check_script() {
  local script="$1"
  echo "Checking $script..."
  if shellcheck "$script"; then
    echo "✓ $script passed"
  else
    echo "✗ $script has issues"
    errors_found=1
  fi
  echo ""
}

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check all shell scripts in the repository
check_script "$SCRIPT_DIR/install.sh"
check_script "$SCRIPT_DIR/uninstall.sh"
check_script "$SCRIPT_DIR/aliases.sh"
check_script "$SCRIPT_DIR/validate.sh"

# Report results
echo "========================================"
if [ $errors_found -eq 0 ]; then
  echo "✓ All shell scripts passed validation!"
  exit 0
else
  echo "✗ Some shell scripts have issues. Please fix them."
  exit 1
fi

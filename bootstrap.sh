#!/bin/bash
#
# Bootstrap script for setting up a development environment on macOS or Linux
# Installs essential development tools and dependencies
#
set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
  echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
  echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
  echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

# Detect OS
detect_os() {
  case "$(uname -s)" in
    Darwin*)
      OS="macos"
      print_info "Detected macOS"
      ;;
    Linux*)
      OS="linux"
      print_info "Detected Linux"
      # Detect Linux distribution
      if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
        print_info "Distribution: $DISTRO"
      fi
      ;;
    *)
      print_error "Unsupported operating system"
      exit 1
      ;;
  esac
}

# Check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Install Homebrew on macOS
install_homebrew() {
  if [ "$OS" = "macos" ]; then
    if ! command_exists brew; then
      print_info "Installing Homebrew..."
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      print_success "Homebrew installed"
    else
      print_success "Homebrew already installed"
    fi
  fi
}

# Update package manager
update_package_manager() {
  print_info "Updating package manager..."
  if [ "$OS" = "macos" ]; then
    brew update
  elif [ "$OS" = "linux" ]; then
    case "$DISTRO" in
      ubuntu|debian)
        sudo apt update
        ;;
      fedora|rhel|centos)
        sudo dnf check-update || true
        ;;
      arch|manjaro)
        sudo pacman -Sy
        ;;
      *)
        print_warning "Unknown distribution, skipping package manager update"
        ;;
    esac
  fi
  print_success "Package manager updated"
}

# Install a package
install_package() {
  local package=$1
  local brew_name=${2:-$package}
  local apt_name=${3:-$package}
  local dnf_name=${4:-$package}
  local pacman_name=${5:-$package}

  if command_exists "$package"; then
    print_success "$package already installed"
    return 0
  fi

  print_info "Installing $package..."
  if [ "$OS" = "macos" ]; then
    brew install "$brew_name"
  elif [ "$OS" = "linux" ]; then
    case "$DISTRO" in
      ubuntu|debian)
        sudo apt install -y "$apt_name"
        ;;
      fedora|rhel|centos)
        sudo dnf install -y "$dnf_name"
        ;;
      arch|manjaro)
        sudo pacman -S --noconfirm "$pacman_name"
        ;;
      *)
        print_warning "Unknown distribution, cannot install $package"
        return 1
        ;;
    esac
  fi
  print_success "$package installed"
}

# Install Git
install_git() {
  install_package git git git git git
}

# Install curl and wget
install_network_tools() {
  install_package curl curl curl curl curl
  install_package wget wget wget wget wget
}

# Install build essentials
install_build_essentials() {
  if [ "$OS" = "linux" ]; then
    print_info "Installing build essentials..."
    case "$DISTRO" in
      ubuntu|debian)
        sudo apt install -y build-essential pkg-config libssl-dev
        ;;
      fedora|rhel|centos)
        sudo dnf groupinstall -y "Development Tools"
        sudo dnf install -y openssl-devel
        ;;
      arch|manjaro)
        sudo pacman -S --noconfirm base-devel openssl
        ;;
    esac
    print_success "Build essentials installed"
  elif [ "$OS" = "macos" ]; then
    # Check if Xcode Command Line Tools are installed
    if ! xcode-select -p >/dev/null 2>&1; then
      print_info "Installing Xcode Command Line Tools..."
      xcode-select --install
      print_warning "Please complete the Xcode Command Line Tools installation and re-run this script"
      exit 1
    else
      print_success "Xcode Command Line Tools already installed"
    fi
  fi
}

# Install Rust
install_rust() {
  if command_exists rustc && command_exists cargo; then
    print_success "Rust already installed ($(rustc --version))"
    return 0
  fi

  print_info "Installing Rust..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

  # Source cargo env
  if [ -f "$HOME/.cargo/env" ]; then
    source "$HOME/.cargo/env"
  fi

  print_success "Rust installed ($(rustc --version))"
}

# Install Go
install_go() {
  if command_exists go; then
    print_success "Go already installed ($(go version))"
    return 0
  fi

  print_info "Installing Go..."
  if [ "$OS" = "macos" ]; then
    brew install go
  elif [ "$OS" = "linux" ]; then
    case "$DISTRO" in
      ubuntu|debian)
        sudo apt install -y golang-go
        ;;
      fedora|rhel|centos)
        sudo dnf install -y golang
        ;;
      arch|manjaro)
        sudo pacman -S --noconfirm go
        ;;
      *)
        # Install from official binary as fallback
        print_info "Installing Go from official binary..."
        local GO_VERSION="1.21.5"
        local GO_TARBALL="go${GO_VERSION}.linux-amd64.tar.gz"
        wget "https://go.dev/dl/${GO_TARBALL}"
        sudo rm -rf /usr/local/go
        sudo tar -C /usr/local -xzf "$GO_TARBALL"
        rm "$GO_TARBALL"

        # Add to PATH in profile if not already there
        if ! grep -q '/usr/local/go/bin' "$HOME/.profile" 2>/dev/null; then
          echo 'export PATH=$PATH:/usr/local/go/bin' >> "$HOME/.profile"
        fi
        export PATH=$PATH:/usr/local/go/bin
        ;;
    esac
  fi
  print_success "Go installed ($(go version))"
}

# Install neovim
install_neovim() {
  if command_exists nvim; then
    print_success "neovim already installed ($(nvim --version | head -n1))"
    return 0
  fi

  print_info "Installing neovim..."
  if [ "$OS" = "macos" ]; then
    brew install neovim
  elif [ "$OS" = "linux" ]; then
    case "$DISTRO" in
      ubuntu|debian)
        sudo apt install -y neovim
        ;;
      fedora|rhel|centos)
        sudo dnf install -y neovim
        ;;
      arch|manjaro)
        sudo pacman -S --noconfirm neovim
        ;;
    esac
  fi
  print_success "neovim installed"
}

# Install tmux
install_tmux() {
  install_package tmux tmux tmux tmux tmux
}

# Install fzf
install_fzf() {
  if command_exists fzf; then
    print_success "fzf already installed"
    return 0
  fi

  print_info "Installing fzf..."
  if [ "$OS" = "macos" ]; then
    brew install fzf
    # Install useful key bindings and fuzzy completion
    $(brew --prefix)/opt/fzf/install --key-bindings --completion --no-update-rc
  elif [ "$OS" = "linux" ]; then
    case "$DISTRO" in
      ubuntu|debian)
        sudo apt install -y fzf
        ;;
      fedora|rhel|centos)
        sudo dnf install -y fzf
        ;;
      arch|manjaro)
        sudo pacman -S --noconfirm fzf
        ;;
      *)
        # Install from git as fallback
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
        ~/.fzf/install --key-bindings --completion --no-update-rc
        ;;
    esac
  fi
  print_success "fzf installed"
}

# Install Rust-based CLI tools
install_rust_tools() {
  # Ensure cargo is available
  if ! command_exists cargo; then
    print_error "Cargo not found. Please install Rust first."
    return 1
  fi

  # Source cargo env to make sure it's in PATH
  if [ -f "$HOME/.cargo/env" ]; then
    source "$HOME/.cargo/env"
  fi

  # ripgrep (rg)
  if ! command_exists rg; then
    print_info "Installing ripgrep..."
    if [ "$OS" = "macos" ]; then
      brew install ripgrep
    elif [ "$OS" = "linux" ]; then
      case "$DISTRO" in
        ubuntu|debian)
          sudo apt install -y ripgrep
          ;;
        fedora|rhel|centos)
          sudo dnf install -y ripgrep
          ;;
        arch|manjaro)
          sudo pacman -S --noconfirm ripgrep
          ;;
        *)
          cargo install ripgrep
          ;;
      esac
    fi
    print_success "ripgrep installed"
  else
    print_success "ripgrep already installed"
  fi

  # fd-find (fd)
  if ! command_exists fd && ! command_exists fdfind; then
    print_info "Installing fd..."
    if [ "$OS" = "macos" ]; then
      brew install fd
    elif [ "$OS" = "linux" ]; then
      case "$DISTRO" in
        ubuntu|debian)
          sudo apt install -y fd-find
          ;;
        fedora|rhel|centos)
          sudo dnf install -y fd-find
          ;;
        arch|manjaro)
          sudo pacman -S --noconfirm fd
          ;;
        *)
          cargo install fd-find
          ;;
      esac
    fi
    print_success "fd installed"
  else
    print_success "fd already installed"
  fi

  # exa (modern ls replacement)
  if ! command_exists exa; then
    print_info "Installing exa..."
    if [ "$OS" = "macos" ]; then
      brew install exa
    elif [ "$OS" = "linux" ]; then
      case "$DISTRO" in
        ubuntu|debian)
          # exa is not in default Ubuntu repos, install via cargo
          cargo install exa
          ;;
        fedora|rhel|centos)
          sudo dnf install -y exa
          ;;
        arch|manjaro)
          sudo pacman -S --noconfirm exa
          ;;
        *)
          cargo install exa
          ;;
      esac
    fi
    print_success "exa installed"
  else
    print_success "exa already installed"
  fi

  # bat (better cat)
  if ! command_exists bat; then
    print_info "Installing bat..."
    if [ "$OS" = "macos" ]; then
      brew install bat
    elif [ "$OS" = "linux" ]; then
      case "$DISTRO" in
        ubuntu|debian)
          sudo apt install -y bat
          # On Ubuntu/Debian, bat is installed as batcat
          if [ ! -f "$HOME/.local/bin/bat" ] && command_exists batcat; then
            mkdir -p "$HOME/.local/bin"
            ln -sf /usr/bin/batcat "$HOME/.local/bin/bat"
          fi
          ;;
        fedora|rhel|centos)
          sudo dnf install -y bat
          ;;
        arch|manjaro)
          sudo pacman -S --noconfirm bat
          ;;
        *)
          cargo install bat
          ;;
      esac
    fi
    print_success "bat installed"
  else
    print_success "bat already installed"
  fi

  # zoxide (smarter cd)
  if ! command_exists zoxide; then
    print_info "Installing zoxide..."
    if [ "$OS" = "macos" ]; then
      brew install zoxide
    elif [ "$OS" = "linux" ]; then
      case "$DISTRO" in
        ubuntu|debian|fedora|rhel|centos)
          cargo install zoxide --locked
          ;;
        arch|manjaro)
          sudo pacman -S --noconfirm zoxide
          ;;
        *)
          cargo install zoxide --locked
          ;;
      esac
    fi
    print_success "zoxide installed"
  else
    print_success "zoxide already installed"
  fi

  # fastmod (code refactoring tool)
  if ! command_exists fastmod; then
    print_info "Installing fastmod..."
    if [ "$OS" = "macos" ]; then
      brew install fastmod
    else
      cargo install fastmod
    fi
    print_success "fastmod installed"
  else
    print_success "fastmod already installed"
  fi
}

# Install sqlx-cli (referenced in aliases as cargo sqlx)
install_sqlx_cli() {
  if cargo install --list | grep -q sqlx-cli; then
    print_success "sqlx-cli already installed"
    return 0
  fi

  print_info "Installing sqlx-cli..."
  cargo install sqlx-cli
  print_success "sqlx-cli installed"
}

# Install xclip on Linux (for pbcopy/pbpaste aliases)
install_xclip() {
  if [ "$OS" = "linux" ]; then
    if ! command_exists xclip; then
      print_info "Installing xclip..."
      case "$DISTRO" in
        ubuntu|debian)
          sudo apt install -y xclip
          ;;
        fedora|rhel|centos)
          sudo dnf install -y xclip
          ;;
        arch|manjaro)
          sudo pacman -S --noconfirm xclip
          ;;
      esac
      print_success "xclip installed"
    else
      print_success "xclip already installed"
    fi
  fi
}

# Install jq (JSON processor)
install_jq() {
  if command_exists jq; then
    print_success "jq already installed ($(jq --version))"
    return 0
  fi

  print_info "Installing jq..."
  if [ "$OS" = "macos" ]; then
    brew install jq
  elif [ "$OS" = "linux" ]; then
    case "$DISTRO" in
      ubuntu|debian)
        sudo apt install -y jq
        ;;
      fedora|rhel|centos)
        sudo dnf install -y jq
        ;;
      arch|manjaro)
        sudo pacman -S --noconfirm jq
        ;;
    esac
  fi
  print_success "jq installed"
}

# Install htop (interactive process viewer)
install_htop() {
  install_package htop htop htop htop htop
}

# Install tree (directory structure visualization)
install_tree() {
  install_package tree tree tree tree tree
}

# Install Node Version Manager (nvm)
install_nvm() {
  if [ -d "$HOME/.nvm" ] || [ -n "$NVM_DIR" ]; then
    print_success "nvm already installed"
    return 0
  fi

  print_info "Installing nvm (Node Version Manager)..."
  # Get the latest nvm version
  NVM_VERSION="v0.39.7"
  curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh" | bash

  # Source nvm to make it available in current session
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

  print_success "nvm installed"

  # Install latest LTS version of Node.js
  if command_exists nvm; then
    print_info "Installing Node.js LTS via nvm..."
    nvm install --lts
    nvm use --lts
    print_success "Node.js LTS installed ($(node --version 2>/dev/null || echo 'node not in current PATH'))"
  fi
}

# Install Python using uv
install_python_uv() {
  if command_exists uv; then
    print_success "uv already installed ($(uv --version))"
  else
    print_info "Installing uv (Python package installer)..."
    curl -LsSf https://astral.sh/uv/install.sh | sh

    # Add uv to PATH for current session
    export PATH="$HOME/.cargo/bin:$PATH"
    print_success "uv installed"
  fi

  # Check if python3 is installed
  if command_exists python3; then
    print_success "Python already installed ($(python3 --version))"
  else
    print_info "Installing Python via uv..."
    if command_exists uv; then
      # uv can install Python versions
      uv python install 3.12
      print_success "Python installed via uv"
    else
      print_warning "uv not available in current session, Python installation skipped"
      print_info "Please restart your shell and run 'uv python install 3.12' to install Python"
    fi
  fi
}

# Main installation flow
main() {
  print_info "Starting bootstrap process..."
  echo

  # Detect OS
  detect_os
  echo

  # Install Homebrew on macOS
  if [ "$OS" = "macos" ]; then
    install_homebrew
    echo
  fi

  # Update package manager
  update_package_manager
  echo

  # Install essential tools
  print_info "Installing essential tools..."
  install_git
  install_network_tools
  install_build_essentials
  echo

  # Install development tools
  print_info "Installing development tools..."
  install_neovim
  install_tmux
  install_fzf
  install_jq
  install_htop
  install_tree
  echo

  # Install programming languages
  print_info "Installing programming languages..."
  install_rust
  install_go
  install_python_uv
  install_nvm
  echo

  # Install Rust-based CLI tools
  print_info "Installing Rust-based CLI tools..."
  install_rust_tools
  echo

  # Install sqlx-cli
  print_info "Installing additional Rust tools..."
  install_sqlx_cli
  echo

  # Install platform-specific tools
  print_info "Installing platform-specific tools..."
  install_xclip
  echo

  # Summary
  print_success "Bootstrap complete!"
  echo
  print_info "Installed tools:"
  echo "  - Git: $(git --version 2>/dev/null || echo 'not found')"
  echo "  - Rust: $(rustc --version 2>/dev/null || echo 'not found')"
  echo "  - Cargo: $(cargo --version 2>/dev/null || echo 'not found')"
  echo "  - Go: $(go version 2>/dev/null || echo 'not found')"
  echo "  - Python: $(python3 --version 2>/dev/null || echo 'not found')"
  echo "  - uv: $(uv --version 2>/dev/null || echo 'not found')"
  echo "  - Node.js: $(node --version 2>/dev/null || echo 'not found')"
  echo "  - nvm: $(nvm --version 2>/dev/null || echo 'not found')"
  echo "  - Neovim: $(nvim --version 2>/dev/null | head -n1 || echo 'not found')"
  echo "  - tmux: $(tmux -V 2>/dev/null || echo 'not found')"
  echo "  - fzf: $(fzf --version 2>/dev/null || echo 'not found')"
  echo "  - jq: $(jq --version 2>/dev/null || echo 'not found')"
  echo "  - htop: $(htop --version 2>/dev/null | head -n1 || echo 'not found')"
  echo "  - tree: $(tree --version 2>/dev/null | head -n1 || echo 'not found')"
  echo "  - ripgrep: $(rg --version 2>/dev/null | head -n1 || echo 'not found')"
  echo "  - fd: $(fd --version 2>/dev/null || fdfind --version 2>/dev/null || echo 'not found')"
  echo "  - exa: $(exa --version 2>/dev/null | head -n1 || echo 'not found')"
  echo "  - bat: $(bat --version 2>/dev/null || echo 'not found')"
  echo "  - zoxide: $(zoxide --version 2>/dev/null || echo 'not found')"
  echo "  - fastmod: $(fastmod --version 2>/dev/null || echo 'not found')"
  echo
  print_warning "Please restart your shell or run 'source ~/.bashrc' (or ~/.zshrc) to use the new tools"
  print_info "For nvm, you may need to reload your shell config to access it"
  print_info "You may also want to run './install.sh' to set up your dotfiles"
}

# Run main function
main

#!/usr/bin/env bash

# macOS Development Environment Setup Script
# Inspired by FelixKratz dotfiles approach
# Author: Dominic Finn

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SETUP_DIR="$HOME/src/setups"
CONFIG_DIR="$HOME/.config"

# Logging functions
info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running on macOS
check_macos() {
    if [[ "$OSTYPE" != "darwin"* ]]; then
        error "This script is designed for macOS only"
        exit 1
    fi
    success "Running on macOS"
}

# Create necessary directories
create_directories() {
    info "Creating necessary directories..."
    mkdir -p "$SETUP_DIR"
    mkdir -p "$CONFIG_DIR"
    mkdir -p "$HOME/.local/bin"
    success "Directories created"
}

# Install Homebrew
install_homebrew() {
    if command -v brew >/dev/null 2>&1; then
        success "Homebrew already installed"
        return
    fi

    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH for Apple Silicon Macs
    if [[ $(uname -m) == "arm64" ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi

    success "Homebrew installed"
}

# Install packages via Homebrew
install_packages() {
    info "Installing packages via Homebrew..."

    # Update brew first
    brew update

    # Install packages from Brewfile
    if [[ -f "$SETUP_DIR/Brewfile" ]]; then
        brew bundle install --file="$SETUP_DIR/Brewfile"
    else
        warning "Brewfile not found, installing essential packages directly"
        # Essential packages
        brew install --cask ghostty
        brew install neovim
        brew install koekeishiya/formulae/yabai
        brew install koekeishiya/formulae/skhd
        brew tap FelixKratz/formulae
        brew install sketchybar
        brew install font-hack-nerd-font

        # Development tools
        brew install go
        brew install rust
        brew install git
        brew install ripgrep
        brew install fzf
        brew install tree
        brew install jq
        brew install gh

        # Optional but useful
        brew install wget
        brew install curl
    fi

    success "Packages installed"
}

# Setup symbolic links for configurations
setup_symlinks() {
    info "Setting up symbolic links..."

    # Remove existing configs and create symlinks
    declare -A configs=(
        ["nvim"]="$SETUP_DIR/nvim"
        ["yabai"]="$SETUP_DIR/yabai"
        ["skhd"]="$SETUP_DIR/skhd"
        ["sketchybar"]="$SETUP_DIR/sketchybar"
        ["ghostty"]="$SETUP_DIR/ghostty"
    )

    for config in "${!configs[@]}"; do
        target_dir="$CONFIG_DIR/$config"
        source_dir="${configs[$config]}"

        if [[ -d "$source_dir" ]]; then
            # Remove existing config if it's not already a symlink to our setup
            if [[ -e "$target_dir" && ! -L "$target_dir" ]]; then
                warning "Backing up existing $config configuration..."
                mv "$target_dir" "$target_dir.backup.$(date +%Y%m%d_%H%M%S)"
            elif [[ -L "$target_dir" && "$(readlink "$target_dir")" == "$source_dir" ]]; then
                success "$config already linked correctly"
                continue
            fi

            # Create symlink
            ln -sfn "$source_dir" "$target_dir"
            success "Linked $config configuration"
        else
            warning "$source_dir not found, skipping $config"
        fi
    done
}

# Configure Git (if not already configured)
setup_git() {
    info "Checking Git configuration..."

    if ! git config --global user.name >/dev/null 2>&1; then
        read -p "Enter your Git username: " git_username
        git config --global user.name "$git_username"
    fi

    if ! git config --global user.email >/dev/null 2>&1; then
        read -p "Enter your Git email: " git_email
        git config --global user.email "$git_email"
    fi

    # Set useful Git defaults
    git config --global init.defaultBranch main
    git config --global pull.rebase false
    git config --global core.editor nvim

    success "Git configured"
}

# Install Go tools
install_go_tools() {
    if ! command -v go >/dev/null 2>&1; then
        warning "Go not found, skipping Go tools installation"
        return
    fi

    info "Installing Go development tools..."

    # Essential Go tools
    go install golang.org/x/tools/gopls@latest
    go install github.com/go-delve/delve/cmd/dlv@latest
    go install honnef.co/go/tools/cmd/staticcheck@latest
    go install golang.org/x/tools/cmd/goimports@latest
    go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest

    success "Go tools installed"
}

# Install Rust tools
install_rust_tools() {
    if ! command -v cargo >/dev/null 2>&1; then
        warning "Rust/Cargo not found, skipping Rust tools installation"
        return
    fi

    info "Installing Rust development tools..."

    # Essential Rust tools
    rustup component add rust-analyzer
    rustup component add clippy
    rustup component add rustfmt

    success "Rust tools installed"
}

# Setup ZSH additions (preserving existing Zim setup)
setup_zsh() {
    info "Setting up ZSH additions..."

    # Check if Zim is already installed
    if [[ -d "$HOME/.zim" ]]; then
        success "Zim framework already installed"
    else
        warning "Zim framework not found - you may want to install it manually"
        info "Visit: https://zimfw.sh/"
    fi

    # Link additional ZSH configuration
    if [[ -f "$SETUP_DIR/zsh/.zshrc.local" ]]; then
        ln -sfn "$SETUP_DIR/zsh/.zshrc.local" "$HOME/.zshrc.local"
        success "ZSH local configuration linked"
    else
        warning "ZSH local configuration not found in setup directory"
    fi

    # Create .zsh_alias file if it doesn't exist
    if [[ ! -f "$HOME/.zsh_alias" ]]; then
        touch "$HOME/.zsh_alias"
        success "Created .zsh_alias file"
    fi
}

# Start services
start_services() {
    info "Starting services..."

    # Start yabai
    if command -v yabai >/dev/null 2>&1; then
        yabai --start-service || warning "Failed to start yabai service"
        success "Yabai service started"
    fi

    # Start skhd
    if command -v skhd >/dev/null 2>&1; then
        skhd --start-service || warning "Failed to start skhd service"
        success "SKHD service started"
    fi

    # Start sketchybar
    if command -v sketchybar >/dev/null 2>&1; then
        brew services start sketchybar || warning "Failed to start sketchybar service"
        success "SketchyBar service started"
    fi
}

# Main installation function
main() {
    echo -e "${BLUE}"
    echo "=================================================="
    echo "  macOS Development Environment Setup"
    echo "=================================================="
    echo -e "${NC}"

    check_macos
    create_directories
    install_homebrew
    install_packages
    setup_symlinks
    setup_git
    install_go_tools
    install_rust_tools
    setup_zsh
    start_services

    echo -e "${GREEN}"
    echo "=================================================="
    echo "  Installation Complete!"
    echo "=================================================="
    echo -e "${NC}"
    echo
    info "Please restart your terminal or run 'source ~/.zshrc' to apply changes"
    info "For yabai, you may need to disable SIP or configure sudoers file"
    info "Sketchybar uses Felix Kratz's exact configuration from your existing setup"
    echo
    success "Your macOS development environment is ready!"
}

# Run main function
main "$@"

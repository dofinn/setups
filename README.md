# macOS Development Environment Setup

A comprehensive setup script for configuring a new macOS machine with a consistent development environment, inspired by [FelixKratz dotfiles](https://github.com/FelixKratz/dotfiles).

## What Gets Installed

### Core Tools
- **Homebrew** - Package manager for macOS
- **Neovim** - Modern Vim-based editor configured for Go/Rust development
- **Yabai** - Tiling window manager for macOS
- **SKHD** - Simple hotkey daemon for macOS
- **SketchyBar** - Custom status bar (using Felix Kratz's exact configuration)
- **Ghostty** - Fast, feature-rich terminal emulator

### Development Languages
- **Go** - With essential development tools (gopls, delve, staticcheck, etc.)
- **Rust** - With rust-analyzer, clippy, and rustfmt
- **Node.js** - JavaScript runtime
- **Python 3.11** - Python programming language

### CLI Tools
- `ripgrep` - Fast text search tool
- `fzf` - Fuzzy finder
- `tree` - Directory tree viewer
- `jq` - JSON processor
- `bat` - Better cat with syntax highlighting
- `eza` - Better ls replacement
- `zoxide` - Smarter cd command
- `starship` - Cross-shell prompt
- `tmux` - Terminal multiplexer
- `htop` - Process viewer

### Configuration Management
- Preserves your existing **Zim** framework setup
- Maintains your **Spaceship** prompt configuration
- Uses symbolic links to `~/src/setups/` for easy version control
- Adds development-specific aliases and functions via `.zshrc.local`

## Quick Start

1. **One-line installation:**
   ```bash
   curl -fsSL https://raw.githubusercontent.com/yourusername/yourrepo/main/install.sh | bash
   ```

2. **Or clone and run locally:**
   ```bash
   git clone <your-repo-url>
   cd <repo-name>
   ./install.sh
   ```

## Directory Structure

```
~/
├── install.sh                    # Main installation script
└── src/setups/                   # Configuration files
    ├── Brewfile                  # Homebrew packages
    ├── nvim/                     # Neovim configuration
    ├── yabai/                    # Yabai window manager config
    ├── skhd/                     # Keyboard shortcuts
    ├── sketchybar/              # Status bar configuration
    ├── ghostty/                  # Terminal configuration
    └── zsh/
        └── .zshrc.local         # Additional ZSH configuration
```

## Post-Installation

After running the installation script:

1. **Restart your terminal** or run `source ~/.zshrc`
2. **Configure yabai permissions:**
   - You may need to disable SIP (System Integrity Protection)
   - Or configure sudoers file for passwordless yabai execution
3. **Verify installations:**
   - `nvim --version`
   - `go version`
   - `cargo --version`
   - `yabai --version`

## Configuration Details

### Neovim
- Configured with LazyVim as the base
- Go and Rust language servers pre-configured
- Essential plugins for development workflow
- Custom keymaps and options

### Yabai + SKHD
- Tiling window management for macOS
- Keyboard shortcuts for window manipulation
- Integration with SketchyBar for workspace display

### SketchyBar
- Uses Felix Kratz's configuration exactly as referenced
- Custom status bar with system information
- Integration with yabai for workspace indicators

### ZSH Setup
- **Preserves your existing Zim framework**
- Adds development-specific paths and aliases via `.zshrc.local`
- Maintains your Spaceship prompt configuration
- Includes useful functions for development workflow

## Customization

All configurations are stored in `~/src/setups/` and linked to their respective locations. This allows you to:

1. Version control your dotfiles
2. Easily sync across multiple machines
3. Make changes that persist across reinstalls

## Troubleshooting

### Yabai Issues
- **Permission denied**: Configure sudoers or disable SIP
- **Service won't start**: Check Console.app for detailed error messages

### SketchyBar Issues
- **Not displaying**: Ensure the service is running with `brew services list`
- **Configuration errors**: Check the sketchybar configuration in `~/.config/sketchybar/`

### ZSH Issues
- **Prompt not appearing**: Ensure Spaceship prompt is properly installed in your Zim setup
- **Aliases not working**: Check that `.zshrc.local` is being sourced

## Contributing

Feel free to fork this repository and customize it for your own needs. The modular approach makes it easy to add or remove components.

## License

This project is open source and available under the MIT License.
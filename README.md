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
- **omp** - AI coding agent (can1357/tap) configured with Baseten + GLM-5.2

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

### omp + Baseten (AI Coding Agent)
- **omp** installed via `can1357/tap` Homebrew tap
- Configured to use `baseten/zai-org/GLM-5.2:high` as the default model
- Linear MCP server configured via OAuth
- Custom tokyonight theme
- Config files symlinked from `omp/` directory to `~/.omp/agent/`

## Quick Start

1. **Clone and run locally:**
   ```bash
   git clone git@github.com:dofinn/setups.git ~/src/setups
   cd ~/src/setups
   ./install.sh
   ```

2. **After installation, complete the manual steps (see below):**
   - Authenticate omp with Baseten
   - Add API tokens to `~/.zshrc.local`

## Post-Installation Manual Steps

The install script handles everything that can be automated. These steps require manual interaction:

### 1. Authenticate omp with Baseten

```bash
omp auth-broker login baseten
```

This opens a browser for OAuth authentication. The credential is stored in macOS Keychain. The `omp/config.yml` symlink sets `baseten/zai-org/GLM-5.2:high` as the default model — it will work once the Baseten credential exists.

### 2. Add API tokens to ~/.zshrc.local

The install script creates `~/.zshrc.local` from `.zshrc.local.example` if it doesn't exist. Edit it to add your tokens:

```bash
vim ~/.zshrc.local
```

This file is **not tracked in git** (see `.gitignore`). It contains machine-specific secrets:
- `FIREHYDRANT_API_TOKEN`
- `LOGSEQ_API_TOKEN`
- `CHRONOSPHERE_API_TOKEN`
- `DITTO_LICENSE` (path to license file)

### 3. Restart your terminal

```bash
source ~/.zshrc
```

### 4. Configure yabai permissions

- You may need to disable SIP (System Integrity Protection)
- Or configure sudoers file for passwordless yabai execution

### 5. Verify installations

```bash
nvim --version
go version
cargo --version
yabai --version
omp --version
```

## Directory Structure

```
~/src/setups/                       # This repo
├── install.sh                      # Main installation script
├── Brewfile                        # Homebrew package list (declarative)
├── .gitignore                      # Excludes secrets, backups, nvim cache
├── .zshrc                          # ZSH config (tracked, no secrets)
├── .zsh_alias                      # ZSH aliases (tracked)
├── .zshrc.local.example            # Template for machine-specific secrets
├── omp/                            # omp (AI coding agent) config
│   ├── config.yml                  # Model roles, theme, settings
│   ├── mcp.json                    # MCP server config (Linear)
│   └── themes/
│       └── tokyonight.json         # Custom omp theme
├── nvim/                           # Neovim configuration
├── yabai/                          # Yabai window manager config
├── skhd/                          # Keyboard shortcuts
├── sketchybar/                     # Status bar configuration
├── ghostty/                        # Terminal configuration
├── tmux/                           # tmux config and scripts
└── scripts/                       # Utility scripts
```

## Secrets Management

**Never commit secrets to git.** The repo uses a two-layer pattern:

1. **`.zshrc` (tracked)** — shell config, functions, aliases. No secrets.
2. **`~/.zshrc.local` (gitignored)** — machine-specific tokens, sourced by `.zshrc` if it exists.

The `.gitignore` excludes:
- `.zshrc.local` / `*.local`
- `secrets*`
- `.env` / `.env.*`
- `*.bak` / `*.backup.*`

### omp Baseten credential

The Baseten API credential is stored in macOS Keychain (not in any file). To set it up on a new machine:

```bash
omp auth-broker login baseten
```

This cannot be automated — it requires browser-based OAuth.

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
- Adds development-specific paths and aliases via `.zsh_alias`
- AWS SSO helper functions (`aws-login`, `aws-logout`, `aws-sso-profile`)
- Git helper functions (`gpu`, `gcb`, `gwta`)
- Kubernetes helper functions (`tkl`, `klogs`, `klogsf`)
- Machine-specific secrets via `~/.zshrc.local` (not tracked)

### omp (AI Coding Agent)
- Default model: `baseten/zai-org/GLM-5.2:high`
- Theme: tokyonight (custom)
- Memory backend: local
- Autolearn: enabled
- Linear MCP server via OAuth
- Config symlinked from `omp/` to `~/.omp/agent/`

## Syncing to a New Machine

1. **Clone the repo:**
   ```bash
   git clone git@github.com:dofinn/setups.git ~/src/setups
   ```

2. **Run the install script:**
   ```bash
   cd ~/src/setups && ./install.sh
   ```

3. **Authenticate omp with Baseten:**
   ```bash
   omp auth-broker login baseten
   ```

4. **Create ~/.zshrc.local with your tokens:**
   ```bash
   cp ~/src/setups/.zshrc.local.example ~/.zshrc.local
   vim ~/.zshrc.local  # fill in your API tokens
   ```

5. **Restart your terminal:**
   ```bash
   source ~/.zshrc
   ```

## Troubleshooting

### Yabai Issues
- **Permission denied**: Configure sudoers or disable SIP
- **Service won't start**: Check Console.app for detailed error messages

### SketchyBar Issues
- **Not displaying**: Ensure the service is running with `brew services list`
- **Configuration errors**: Check the sketchybar configuration in `~/.config/sketchybar/`

### ZSH Issues
- **Prompt not appearing**: Ensure Spaceship prompt is properly installed in your Zim setup
- **Aliases not working**: Check that `.zsh_alias` is being sourced (it is sourced by `.zshrc`)
- **Secrets not loading**: Ensure `~/.zshrc.local` exists and contains your tokens

### omp Issues
- **Model not working**: Run `omp auth-broker login baseten` to authenticate
- **Config not loading**: Check that `~/.omp/agent/config.yml` is symlinked to the repo
- **Check current model**: `omp config get modelRoles`

## Contributing

Feel free to fork this repository and customize it for your own needs. The modular approach makes it easy to add or remove components.

## License

This project is open source and available under the MIT License.

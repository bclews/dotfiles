# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a dotfiles repository organized for use with GNU Stow, a symlink manager. Each top-level directory represents a package containing configuration files for a specific application, with subdirectories that mirror the target filesystem structure.

## Key Commands

### GNU Stow Operations
- `make stow` or `make` - Stow all configurations (creates symlinks)
- `make unstow` - Unstow all configurations (removes symlinks) 
- `make help` - Show available commands
- `stow <package>` - Stow individual package (e.g., `stow nvim`, `stow alacritty`)

### Individual Package Management
To work with specific configurations:
- `stow nvim` - Install Neovim configuration
- `stow zsh` - Install Zsh configuration  
- `stow alacritty` - Install Alacritty terminal configuration

## Architecture and Structure

### Package Organization
- **nvim/**: Neovim configuration using LazyVim framework
  - Located at `nvim/.config/nvim/` 
  - Uses Lua configuration with lazy.nvim plugin manager
  - Main entry point: `init.lua`
- **zsh/**: Zsh shell configuration
  - Contains `.zshrc` and related shell files
- **alacritty/**: Alacritty terminal emulator configuration  
- **bat/**: Bat (cat alternative) configuration
- **btop/**: System monitor configuration
- **fastfetch/**: System information tool configuration

### File Structure Convention
Files are organized to match their target locations when stowed:
- `nvim/.config/nvim/` → `~/.config/nvim/`
- `zsh/.zshrc` → `~/.zshrc` 
- `alacritty/.config/alacritty/` → `~/.config/alacritty/`

### Excluded Directories
The Makefile automatically excludes `.git` and `@notes` directories from stowing operations.

## Development Notes

- The repository uses GNU Stow's directory structure convention
- Configuration changes should be made within the appropriate package directory
- The Neovim configuration is based on LazyVim and includes a workaround for LSP file watching issues
- No traditional build/test/lint commands as this is a configuration repository

### Git Configuration Security

The git package uses an include pattern to separate sensitive data:
- `git/.gitconfig` contains public configuration (committed to repo)
- `~/.gitconfig.local` contains sensitive data like signing keys (local only, not committed)
- When setting up on a new machine, create `~/.gitconfig.local` with your signing key:
  ```
  [user]
    signingkey = your-ssh-key-here
  ```
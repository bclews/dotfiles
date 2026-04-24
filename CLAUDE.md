# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a dotfiles repository organized for use with GNU Stow, a symlink manager. Each top-level directory represents a package containing configuration files for a specific application, with subdirectories that mirror the target filesystem structure.

Supported platforms: macOS and Ubuntu 22.04+. The `bootstrap.sh` script at the repo root installs prerequisites on either OS and then runs `make stow`. See `docs/ubuntu-setup.md` for Linux-specific notes.

## Key Commands

### Bootstrap
- `./bootstrap.sh` - Detect OS, install all prerequisites, and stow. Idempotent.

### GNU Stow Operations
- `make stow` or `make` - Stow all configurations for the current OS (creates symlinks)
- `make unstow` - Unstow all configurations for the current OS (removes symlinks)
- `make list` - Show which packages would be stowed (useful for debugging OS detection)
- `make completions` - Regenerate cached zsh completions into `~/.cache/zsh-completions/`
- `make help` - Show available commands
- `stow <package>` - Stow individual package (e.g., `stow nvim`, `stow alacritty`)
- `SKIP_LOCAL="pkg1 pkg2" make` - Skip specific packages on this machine regardless of OS

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
The Makefile uses `$(wildcard */)` to enumerate packages, which naturally skips dotdirs (`.git`, `.claude`). The `@notes` directory is explicitly filtered out. A per-OS `SKIP_OS` list excludes packages that have no meaning on the target OS — currently `hammerspoon` on Linux, nothing on macOS.

## Development Notes

- The repository uses GNU Stow's directory structure convention
- Configuration changes should be made within the appropriate package directory
- The `bootstrap.sh` script pins tool versions and verifies SHA256 checksums where upstream publishes them; bump the version constants at the top of the script periodically
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

### Zsh Plugin and Prompt Architecture

The zsh package uses [antidote](https://getantidote.github.io/) for plugin management and [starship](https://starship.rs/) for the prompt (replacing oh-my-zsh + powerlevel10k; see commit history for rationale).

**File layout**
- `zsh/.zshrc` — main config. Load order matters: `fpath` → `compinit` → **`antidote load`** → paths → tool integrations → aliases → prompt → keybindings. Antidote is loaded early so `_evalcache` is available for the sections that follow.
- `zsh/.zsh/plugins.txt` — antidote plugin list, one `<user>/<repo>` per line. Committed. Current order:
  1. `mroth/evalcache` — must come first so `_evalcache` is defined before anything calls it
  2. `zsh-users/zsh-autosuggestions`
  3. `zsh-users/zsh-syntax-highlighting` — must be last so it wraps all previously-registered widgets
- `zsh/.zsh/plugins.zsh` — antidote's compiled bundle, written on first shell start. Contains absolute cache paths, gitignored.
- `zsh/.zsh/keybindings.zsh` — custom ZLE bindings (e.g., prefix-matched history search on arrow keys).
- `zsh/.zsh/functions/` and `zsh/.zsh/completions/` — custom shell functions and completions committed to the repo.
- `~/.cache/zsh-completions/` — tool-generated completions from `kubectl`, `helm`, `gh`, `docker`, `minikube`. Regenerate with `make completions` after upgrading any of those tools. Not committed (tool-version-specific).

**Startup optimizations (Tier 1 / Tier 2)**

The zshrc uses several idiomatic techniques to keep steady-state startup near ~200ms:

1. **`_evalcache` (from `mroth/evalcache`)** wraps every subprocess-based init:
   ```zsh
   _evalcache starship init zsh
   _evalcache zoxide init zsh
   _evalcache fzf --zsh
   _evalcache mise activate zsh --shims
   ```
   The cache lives in `~/.zsh-evalcache/`, keyed by the binary's mtime — upgrading the tool (e.g., `brew upgrade starship`) invalidates and regenerates automatically. First shell after an upgrade pays the subprocess cost once.

2. **mise runs in `--shims` mode**, which adds `~/.local/share/mise/shims` to PATH but skips the `chpwd` hook. Tool versions still resolve per-directory via the shims reading `mise.toml`/`.tool-versions` at invocation. **Tradeoff**: mise's `[env]` per-project env-var injection is not applied — if you add a project that needs it, switch that project's block out or revert to full `mise activate zsh`.

3. **`compinit` skips the audit on fresh zcompdumps.** The full security audit (`compaudit`) only runs when `~/.zcompdump` is older than 24 hours; otherwise `compinit -C` is used. This saves ~25ms per shell start.

4. **No subprocess paths in PATH exports.** `$(go env GOPATH)/bin` was replaced with the hardcoded default `$HOME/go/bin`; `$(/usr/libexec/java_home)` was removed entirely along with Java's openjdk PATH entry (re-add when needed).

### jj Configuration Security

The jj package uses jj's multi-file config directory support to separate sensitive data:
- `jj/.config/jj/config.toml` contains public configuration (committed to repo)
- `~/.config/jj/user.toml` contains name and email (local only, not committed)
- When setting up on a new machine, create `~/.config/jj/user.toml`:
  ```toml
  [user]
  name = "Your Name"
  email = "your@email.com"
  ```
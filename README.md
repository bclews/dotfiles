# Dotfiles

This repository contains my dotfiles, making it easier to manage and version-control them across different systems. It is organised for use with [GNU Stow](https://www.gnu.org/software/stow/), a symlink manager. The blog post [Using GNU Stow to manage your dotfiles](https://brandon.invergo.net/news/2012-05-26-using-gnu-stow-to-manage-your-dotfiles.html) does an excellent of job explaining this approach.

## Structure

The structure of this repository is:

1. **Each top-level directory is a package:** These directories correspond to individual applications or sets of related configuration files.
2. **Subdirectories mimic the target directory structure:** Inside each package, the directory structure should match where the files will be placed on the target system.

The table below shows how GNU Stow maps dotfiles to their corresponding locations in the GNU Stow directory structure. The arrows indicate the transformation from the original dotfile location to the GNU Stow convention.

| Dotfile               |                                  | GNU Stow Path                 |
|-----------------------|----------------------------------|-------------------------------|
| `~/.config/nvim`      | &#8594;                          | `nvim/.config/nvim`           |
| `~/.config/alacritty` | &#8594;                          | `alacritty/.config/alacritty` |
| `~/.zshrc`            | &#8594;                          | `zsh/.zshrc`                  |
| `~/.gitconfig`        | &#8594;                          | `git/.gitconfig`              |

## Supported platforms

- macOS (Apple Silicon or Intel, Homebrew required)
- Ubuntu 22.04 LTS or newer

## Quick start

Clone and run the bootstrap script. It detects the OS, installs prerequisites, and runs `make stow`.

```sh
git clone git@github.com:bclews/dotfiles.git ~/dotfiles
cd ~/dotfiles
./bootstrap.sh
```

The script is idempotent — safe to re-run after adding packages or bumping tool versions.

### What bootstrap.sh does

| Step                | macOS                              | Ubuntu                                                              |
|---------------------|------------------------------------|---------------------------------------------------------------------|
| Package manager     | Homebrew (must exist)              | `apt` + signed upstream repos for `gh` and `mise`                   |
| Modern git          | `brew install git`                 | `git-core` PPA (git 2.34 in stock 22.04 predates `zdiff3`)          |
| Shell + stow        | `brew install zsh stow`            | `apt install zsh stow`                                              |
| Plugin manager      | `brew install antidote`            | `git clone` pinned to a release tag into `~/.antidote`              |
| User tools          | `brew install` formulae list       | GitHub release tarballs with SHA256 verification into `~/.local/bin`|
| Stow configs        | `make stow` (skips none)           | `make stow` (skips `hammerspoon`)                                   |

See `docs/ubuntu-setup.md` for the full Ubuntu walkthrough, including gotchas and manual-install alternatives.

### Post-bootstrap steps

The script prints these on completion.

- **Make zsh your login shell.** On macOS, `chsh` only accepts shells listed in `/etc/shells`, and Apple's system `/bin/zsh` is what `chsh -s "$(command -v zsh)"` from a bash prompt will resolve to — not what you want. Use brew's zsh explicitly:

  ```sh
  # macOS
  echo "$(brew --prefix)/bin/zsh" | sudo tee -a /etc/shells
  chsh -s "$(brew --prefix)/bin/zsh"

  # Ubuntu (apt's zsh is already in /etc/shells)
  chsh -s "$(command -v zsh)"
  ```

- Fill in `~/.gitconfig.local` with your name/email/signing key (see [Git Configuration Security](#git-configuration-security))
- Start a new shell: `exec zsh`

## Manual install

If you prefer to skip the script and stow packages by hand:

```sh
git clone git@github.com:bclews/dotfiles.git ~/dotfiles
cd ~/dotfiles
stow alacritty bat btop git nvim zsh   # pick whichever packages you want
```

You are responsible for installing the tools those configs reference (`zsh`, `starship`, `fzf`, `zoxide`, `mise`, etc.) via your own package manager.

## Makefile

The `Makefile` wraps common operations and is OS-aware (detects macOS vs Linux via `uname -s`).

- `make stow` - Stow all configurations for this OS
- `make unstow` - Unstow all configurations for this OS
- `make list` - Show which packages would be stowed (useful for debugging OS detection)
- `make completions` - Regenerate cached zsh completions (after upgrading `kubectl`, `helm`, `gh`, `docker`, or `minikube`)
- `make help` - Show help

To skip a package on a specific machine regardless of OS:

```sh
SKIP_LOCAL="op 1Password" make stow
```

## Zsh Startup Caches

Subprocess-based shell inits (`starship`, `zoxide`, `fzf`, `mise`) are wrapped in `_evalcache` (from the [mroth/evalcache](https://github.com/mroth/evalcache) antidote plugin) so their output is cached to `~/.zsh-evalcache/` rather than regenerated on every shell start.

The cache is keyed by each tool binary's modification time, which means:

- **After upgrading any wrapped tool** (`brew upgrade`, `apt upgrade`, or re-running `./bootstrap.sh` with bumped version pins), the next shell pays the subprocess cost once while the cache refreshes — expect a one-time startup blip. Every shell after that is fast again.
- **To force a full refresh manually**, run `rm -rf ~/.zsh-evalcache`.

Tool-generated completions (`kubectl`, `helm`, `gh`, `docker`, `minikube`) live in a separate cache at `~/.cache/zsh-completions/` and are regenerated manually via `make completions`.

## Git Configuration Security

The git package uses an include pattern to separate sensitive data from the repository:

- `git/.gitconfig` contains public configuration (committed to repo)
- `~/.gitconfig.local` contains sensitive data like signing keys (local only, never committed)

**Setup on new machines:**
After stowing the git package, create `~/.gitconfig.local` with your personal information:

```ini
[user]
  signingkey = your-ssh-key-here
  email = your-email@example.com
  name = Your Name
```

## Adding New Configurations

To add a new configuration:

1. Create a new directory for the application inside the `dotfiles` directory.
2. Add the configuration files, ensuring the directory structure matches the target location.
3. Use `stow` to create symlinks for the new configuration.

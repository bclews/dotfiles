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

## Prerequisites

Ensure you have GNU Stow installed. You can install it via Homebrew on macOS:

```sh
brew install stow
```

## Installation

1. Clone the repository to your home directory:

```sh
git clone git@github.com:yourusername/dotfiles.git ~/dotfiles
```

2. Navigate to the `dotfiles` directory:

```sh
cd ~/dotfiles
```

3. Use GNU Stow to create symlinks for the desired configuration packages. For example:

```sh
stow alacritty
stow bat
stow btop
stow neofetch
stow nvim
```

This will create symlinks in the appropriate locations (e.g., `~/.config/alacritty`).

## Makefile

A `Makefile` is provided for convenience. You can use it to stow and unstow all configurations at once.

### Usage

- **Stow all configurations**:

```sh
make stow
```

- **Unstow all configurations**:

```sh
make unstow
```

- **Show help message**:

```sh
make help
```

## Adding New Configurations

To add a new configuration:

1. Create a new directory for the application inside the `dotfiles` directory.
2. Add the configuration files, ensuring the directory structure matches the target location.
3. Use `stow` to create symlinks for the new configuration.

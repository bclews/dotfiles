# Ubuntu Setup

Walks through bootstrapping these dotfiles on Ubuntu 22.04 LTS (and up). For macOS, just run `./bootstrap.sh` — the bits below are Ubuntu-specific.

## Prerequisites

- Ubuntu 22.04 or newer, `x86_64` or `aarch64`
- A user account with `sudo` access (the bootstrap uses `sudo` for `apt`)
- Outbound HTTPS to `github.com`, `cli.github.com`, `mise.jdx.dev`, `launchpad.net`

That's it. You do **not** need to pre-install zsh, stow, or any of the user tools — the script handles all of them.

## Run the bootstrap

```sh
git clone https://github.com/bclews/dotfiles.git ~/dotfiles
cd ~/dotfiles
./bootstrap.sh
```

Re-running is safe; every install step checks for the already-installed version and skips.

## What gets installed

### apt base packages (from Ubuntu's signed archive)

`zsh`, `stow`, `make`, `curl`, `ca-certificates`, `gpg`, `software-properties-common`, `bat`, `fd-find`, `ripgrep`.

### git-core PPA (signed, maintained by the git project)

Ubuntu 22.04 ships git 2.34. The stowed `.gitconfig` uses `merge.conflictstyle = zdiff3`, which was added in git 2.35, so the bootstrap adds the `ppa:git-core/ppa` repository and upgrades git to the latest stable release.

### Signed upstream apt repos

| Tool   | Repo                         | Keyring                                        |
|--------|------------------------------|------------------------------------------------|
| `gh`   | `cli.github.com/packages`    | `/etc/apt/keyrings/githubcli.gpg`              |
| `mise` | `mise.jdx.dev/deb`           | `/etc/apt/keyrings/mise.gpg`                   |

Each keyring is fetched over HTTPS, dearmored with `gpg`, and referenced from the corresponding `/etc/apt/sources.list.d/*.list` entry via `signed-by=`.

### Binaries from GitHub releases

Pinned versions, downloaded from each project's official release page into `~/.local/bin/`. SHA256 verification is used where the upstream publishes a checksum file:

| Tool        | Version  | Checksum source                            |
|-------------|----------|--------------------------------------------|
| `starship`  | 1.25.0   | Per-asset `.sha256` companion              |
| `fzf`       | 0.68.0   | Combined `fzf_0.68.0_checksums.txt`        |
| `neovim`    | 0.11.2   | Combined `shasum.txt`                      |
| `zoxide`    | 0.9.9    | None published — HTTPS-only (installed as `.deb`) |
| `eza`       | 0.23.4   | None published — HTTPS-only                |

Bump any of these by editing the version constants at the top of `bootstrap.sh` and re-running.

### antidote

Cloned from `https://github.com/mattmc3/antidote` to `~/.antidote`, pinned to release tag `v1.9.7`.

## Binary renames and PATH

Ubuntu renames two binaries that the dotfiles call by their upstream names:

| Upstream | Ubuntu binary | Fix                                       |
|----------|---------------|-------------------------------------------|
| `bat`    | `batcat`      | Symlinked to `~/.local/bin/bat`           |
| `fd`     | `fdfind`      | Symlinked to `~/.local/bin/fd`            |

`~/.local/bin` is prepended to `PATH` in `.zshrc`, so both resolve normally once you start zsh.

## Post-install checklist

The bootstrap prints these; they are one-time manual steps:

```sh
# 1. Make zsh your login shell (requires your password)
chsh -s "$(command -v zsh)"

# 2. Fill in ~/.gitconfig.local (name, email, signingkey)
$EDITOR ~/.gitconfig.local

# 3. Start zsh
exec zsh
```

If you use `gh` for HTTPS auth to GitHub:

```sh
gh auth login
```

## Known gotchas

- **`TERM=ghostty`**: the `.zshrc` only exports `TERM=ghostty` when the ghostty terminfo entry is present. On a headless Ubuntu box without ghostty, `TERM` stays whatever your terminal set it to. If you SSH in from a Ghostty terminal on macOS and want full rendering, install the terminfo entry manually with `tic`.
- **`hammerspoon/`** is macOS-only and is skipped by the Makefile on Linux — it will not be stowed.
- **`make completions`** requires `kubectl`, `helm`, `gh`, `docker`, and `minikube` to be installed. The bootstrap only installs `gh`; add the others yourself if you need their completions regenerated.
- **`mise` is installed but not used by the bootstrap itself.** It's available for your project-level tool version management (see `mise.toml`/`.tool-versions`). The bootstrap deliberately pins user tools to specific releases rather than using `mise` for install, so the setup is reproducible across machines regardless of registry availability.

## Skipping packages on a specific machine

If there's a package you don't want on this host (say, you don't use `1Password`):

```sh
SKIP_LOCAL="1Password op" make stow
```

`SKIP_LOCAL` combines with the OS-level skip list, so hammerspoon stays skipped too.

## Manual install (no bootstrap)

If you want to cherry-pick rather than run the whole script:

```sh
sudo apt install -y zsh stow git make curl bat fd-find ripgrep
mkdir -p ~/.local/bin
ln -s /usr/bin/batcat ~/.local/bin/bat
ln -s /usr/bin/fdfind ~/.local/bin/fd

git clone --depth=1 --branch=v1.9.7 https://github.com/mattmc3/antidote.git ~/.antidote

# Install starship, zoxide, fzf, eza, neovim, gh, mise yourself — the
# bootstrap script is the authoritative reference for how.

cd ~/dotfiles && make stow
chsh -s "$(command -v zsh)"
```

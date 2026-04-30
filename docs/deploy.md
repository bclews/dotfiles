# Deploying this repo

This repo is "deployed" by merging to `main` and then pulling the new commit on each machine that uses these dotfiles. There is no build artifact, no CI, no release tag — `main` is the source of truth and every machine has its own clone.

## 1. Land the branch

Open a PR and merge it (squash or merge commit, your call):

```sh
gh pr create --base main --fill
gh pr merge --squash --delete-branch
```

Or skip the PR and merge locally:

```sh
git checkout main && git pull
git merge --no-ff multi-user-deploy
git push origin main
git push origin --delete multi-user-deploy
git branch -d multi-user-deploy
```

## 2. Roll it out per machine

### macOS (your laptop)

```sh
cd ~/dotfiles
git pull
make stow            # picks up any new packages
```

If the branch added new tool versions in `bootstrap.sh`, also run:

```sh
./bootstrap.sh       # idempotent; only re-installs what changed
```

### Ubuntu VM, single user

```sh
cd ~/dotfiles
git pull
./bootstrap.sh       # full system + user phase
```

### Ubuntu VM, multiple users (the case this branch is built for)

The `multi-user-deploy` branch split `bootstrap.sh` into `--system-only` and `--user-only` phases so service accounts and `root` can stow without sudo.

> **Before you start**: the multi-user split only exists on `main` once this branch is merged. If you're still testing pre-merge, clone the branch explicitly with `git clone -b multi-user-deploy ...` instead of plain `git clone ...` — otherwise the user picks up `main`'s pre-split `bootstrap.sh` (or no `bootstrap.sh` at all) and `--user-only` is silently a no-op.
>
> Order also matters: a sudo-capable user must run the system phase first so `/usr/local/bin/{starship,nvim,fzf,eza,lazygit}` exist before service accounts run `--user-only`. Verify with `command -v starship nvim fzf eza lazygit`.

On a fresh VM:

```sh
# 1. Personal user (has sudo): runs both phases — this is what installs the
#    system tools that all subsequent users will share.
git clone https://github.com/bclews/dotfiles.git ~/dotfiles
cd ~/dotfiles && ./bootstrap.sh

# 2. Service account (no sudo): user phase only, AFTER step 1 has run
sudo su - sa-rema
git clone https://github.com/bclews/dotfiles.git ~/dotfiles
cd ~/dotfiles && ./bootstrap.sh --user-only

# 3. Root (so `sudo -i` matches your shell): user phase, skip git identity
sudo -i
git clone https://github.com/bclews/dotfiles.git ~/dotfiles
cd ~/dotfiles && SKIP_LOCAL=git ./bootstrap.sh --user-only
```

If `./bootstrap.sh --user-only` prompts for a sudo password, the clone is on a branch/commit that predates the system/user split. Verify with:

```sh
cd ~/dotfiles
git rev-parse --abbrev-ref HEAD          # should be main (post-merge) or multi-user-deploy
grep -c -- '--user-only' bootstrap.sh    # 0 means the script is too old
```

Re-clone with `-b multi-user-deploy` (pre-merge) or `git pull` (post-merge) to fix.

On an existing VM that already ran the system phase, just `git pull && make stow` per user — re-run `./bootstrap.sh --system-only` only if a tool version bumped in `bootstrap.sh`.

## 3. Post-merge sanity checks

```sh
chsh -s "$(command -v zsh)"     # only if zsh isn't already login shell
$EDITOR ~/.gitconfig.local      # name, email, signingkey (per user, never committed)
$EDITOR ~/.config/jj/user.toml  # name, email for jj (per user, never committed)
exec zsh
```

For service accounts (no password), `chsh` fails with `PAM: Authentication failure`. Set the shell from a sudo-capable account instead — `sudo` skips the PAM password check:

```sh
sudo chsh -s "$(command -v zsh)" sa-rema
getent passwd sa-rema | cut -d: -f7   # confirm: /usr/bin/zsh
```

If you have no sudo on the VM, append `[[ -z "$ZSH_VERSION" ]] && exec zsh -l` to the service account's `~/.bashrc` so login bash re-execs into zsh.

See `docs/ubuntu-setup.md` for the authoritative list of what each phase installs and the known gotchas (terminfo over SSH, pre-existing `~/.zshrc` blocking stow, etc.).

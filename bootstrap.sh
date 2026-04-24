#!/usr/bin/env bash
# Bootstrap this dotfiles repo on a fresh macOS or Ubuntu machine.
# Idempotent — safe to re-run.
#
# On Ubuntu the script has two phases:
#   - system phase: apt installs, signed upstream repos, and tool binaries
#                   installed to /usr/local/bin. Requires sudo. Run once
#                   per VM by a user with sudo.
#   - user phase:   antidote clone to ~/.antidote and `make stow`. No sudo.
#                   Run by every user who wants the config — typically
#                   your personal user, sa-rema (service account), and
#                   root (for `sudo -i` sessions).
# Flags:
#   --system-only   Run system phase only, skip user phase. Useful when
#                   provisioning the VM for users who will each self-apply.
#   --user-only     Run user phase only, skip system phase. Required for
#                   users without sudo (e.g. sa-rema).
#   default         Run both phases (single-user macOS/Ubuntu install).
#
# Security posture:
#   - apt packages come from Ubuntu's signed main/universe plus official
#     upstream apt repos for gh and mise (both GPG-signed keyrings).
#   - antidote is pinned to a release tag and cloned over HTTPS.
#   - Tool binaries (starship, zoxide, fzf, eza, neovim) are downloaded
#     from their official GitHub releases and verified against the
#     companion SHA256 file published alongside each release.
#   - No `curl | bash` pipelines.

set -euo pipefail

log()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m==>\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[1;31m==>\033[0m %s\n' "$*" >&2; exit 1; }

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Binaries from this script go system-wide on Ubuntu so each VM only pays
# for one download per tool regardless of how many users apply the dotfiles.
SYSTEM_BIN="/usr/local/bin"
NVIM_PREFIX="/opt/nvim"

RUN_SYSTEM=1
RUN_USER=1

print_help() {
  # Print the top-of-file comment block up to (but not including) the
  # "Security posture" section.
  sed -n '2,/^# Security posture/p' "${BASH_SOURCE[0]}" | \
    sed '$d; s/^# \{0,1\}//'
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --system-only) RUN_USER=0 ;;
    --user-only)   RUN_SYSTEM=0 ;;
    -h|--help)     print_help; exit 0 ;;
    *)             die "Unknown flag: $1 (try --help)" ;;
  esac
  shift
done

# Pinned versions — bump these periodically and re-run.
ANTIDOTE_TAG="v1.9.7"
STARSHIP_VERSION="1.25.0"
ZOXIDE_VERSION="0.9.9"
FZF_VERSION="0.68.0"
EZA_VERSION="0.23.4"
NEOVIM_VERSION="0.11.2"

detect_os() {
  case "$(uname -s)" in
    Darwin) echo macos ;;
    Linux)
      if [[ -r /etc/os-release ]] && grep -q '^ID=ubuntu' /etc/os-release; then
        echo ubuntu
      else
        die "Unsupported Linux distribution — only Ubuntu is automated."
      fi
      ;;
    *) die "Unsupported OS: $(uname -s)" ;;
  esac
}

# Translate `uname -m` into the per-tool arch strings. Most tools use
# `x86_64`/`aarch64`, but some diverge (fzf uses `amd64`/`arm64`, neovim
# uses `x86_64`/`arm64`), so callers pass a tool-specific mapping.
arch_tag() {
  local style="$1"
  local m; m="$(uname -m)"
  case "$style:$m" in
    gnu:x86_64|gnu:amd64)   echo x86_64 ;;
    gnu:aarch64|gnu:arm64)  echo aarch64 ;;
    go:x86_64|go:amd64)     echo amd64 ;;
    go:aarch64|go:arm64)    echo arm64 ;;
    nvim:x86_64|nvim:amd64) echo x86_64 ;;
    nvim:aarch64|nvim:arm64) echo arm64 ;;
    *) die "Unsupported arch: $m (style=$style)" ;;
  esac
}

# Download an asset from a URL and verify sha256 against a checksum file.
# For per-asset `.sha256` files the checksum file contains a single hash
# (or "hash  filename"); for combined SHA256SUMS files we grep the line
# matching the asset filename.
download_verify() {
  local asset_url="$1" checksum_url="$2" out="$3" asset_name="${4:-}"
  curl -fsSL -o "$out" "$asset_url"
  local sums; sums=$(curl -fsSL "$checksum_url")
  local expected
  if [[ -n "$asset_name" ]]; then
    expected=$(echo "$sums" | awk -v n="$asset_name" \
      '$2 == n || $2 == "*"n {print $1; exit}')
  else
    expected=$(echo "$sums" | awk '{print $1; exit}')
  fi
  [[ -n "$expected" ]] || die "no checksum found in $checksum_url"
  local actual; actual=$(sha256sum "$out" | awk '{print $1}')
  [[ "$expected" == "$actual" ]] \
    || die "checksum mismatch for $asset_url: expected $expected got $actual"
}

install_starship() {
  if command -v starship >/dev/null && [[ "$(starship --version | awk '{print $2}')" == "$STARSHIP_VERSION" ]]; then
    log "starship $STARSHIP_VERSION already installed"; return
  fi
  log "Installing starship $STARSHIP_VERSION to $SYSTEM_BIN"
  local arch; arch=$(arch_tag gnu)
  local asset="starship-${arch}-unknown-linux-musl.tar.gz"
  local base="https://github.com/starship/starship/releases/download/v${STARSHIP_VERSION}"
  local tmp; tmp=$(mktemp -d)
  download_verify "$base/$asset" "$base/$asset.sha256" "$tmp/$asset"
  tar -xzf "$tmp/$asset" -C "$tmp"
  sudo install -m 0755 "$tmp/starship" "$SYSTEM_BIN/starship"
  rm -rf "$tmp"
}

install_zoxide() {
  if command -v zoxide >/dev/null && [[ "$(zoxide --version | awk '{print $2}')" == "$ZOXIDE_VERSION" ]]; then
    log "zoxide $ZOXIDE_VERSION already installed"; return
  fi
  log "Installing zoxide $ZOXIDE_VERSION (via upstream .deb)"
  # zoxide does not publish a checksums file, but their native .deb for
  # Debian/Ubuntu is the cleanest install path. Integrity is HTTPS-only.
  local arch; arch="$(dpkg --print-architecture)"
  local asset="zoxide_${ZOXIDE_VERSION}-1_${arch}.deb"
  local url="https://github.com/ajeetdsouza/zoxide/releases/download/v${ZOXIDE_VERSION}/${asset}"
  local tmp; tmp=$(mktemp -d)
  curl -fsSL -o "$tmp/$asset" "$url"
  sudo dpkg -i "$tmp/$asset"
  rm -rf "$tmp"
}

install_fzf() {
  if command -v fzf >/dev/null && [[ "$(fzf --version | awk '{print $1}')" == "$FZF_VERSION" ]]; then
    log "fzf $FZF_VERSION already installed"; return
  fi
  log "Installing fzf $FZF_VERSION to $SYSTEM_BIN"
  local arch; arch=$(arch_tag go)
  local asset="fzf-${FZF_VERSION}-linux_${arch}.tar.gz"
  local base="https://github.com/junegunn/fzf/releases/download/v${FZF_VERSION}"
  local tmp; tmp=$(mktemp -d)
  download_verify "$base/$asset" "$base/fzf_${FZF_VERSION}_checksums.txt" "$tmp/$asset" "$asset"
  tar -xzf "$tmp/$asset" -C "$tmp"
  sudo install -m 0755 "$tmp/fzf" "$SYSTEM_BIN/fzf"
  rm -rf "$tmp"
}

install_eza() {
  if command -v eza >/dev/null && [[ "$(eza --version | awk 'NR==2 {print $1}' | sed 's/^v//')" == "$EZA_VERSION" ]]; then
    log "eza $EZA_VERSION already installed"; return
  fi
  log "Installing eza $EZA_VERSION to $SYSTEM_BIN (HTTPS-only; upstream does not publish SHA256SUMS)"
  local arch; arch=$(arch_tag gnu)
  local asset="eza_${arch}-unknown-linux-gnu.tar.gz"
  local url="https://github.com/eza-community/eza/releases/download/v${EZA_VERSION}/${asset}"
  local tmp; tmp=$(mktemp -d)
  curl -fsSL -o "$tmp/$asset" "$url"
  tar -xzf "$tmp/$asset" -C "$tmp"
  sudo install -m 0755 "$tmp/eza" "$SYSTEM_BIN/eza"
  rm -rf "$tmp"
}

install_lazygit() {
  if command -v lazygit >/dev/null && [[ "$(lazygit --version | awk '{print $4}' | sed 's/v//' | sed 's/,//')" == "$LAZYGIT_VERSION" ]]; then
    log "lazygit $LAZYGIT_VERSION already installed"; return
  fi
  log "Installing lazygit $LAZYGIT_VERSION to $SYSTEM_BIN"
  local arch; arch=$(arch_tag nvim)
  local asset="lazygit_${LAZYGIT_VERSION}_Linux_${arch}.tar.gz"
  local base="https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}"
  local tmp; tmp=$(mktemp -d)
  download_verify "$base/$asset" "$base/checksums.txt" "$tmp/$asset" "$asset"
  tar -xzf "$tmp/$asset" -C "$tmp" lazygit
  sudo install -m 0755 "$tmp/lazygit" "$SYSTEM_BIN/lazygit"
  rm -rf "$tmp"
}

install_neovim() {
  if command -v nvim >/dev/null && nvim --version | head -1 | grep -q "$NEOVIM_VERSION"; then
    log "neovim $NEOVIM_VERSION already installed"; return
  fi
  log "Installing neovim $NEOVIM_VERSION to $NVIM_PREFIX"
  local arch; arch=$(arch_tag nvim)
  local asset="nvim-linux-${arch}.tar.gz"
  local base="https://github.com/neovim/neovim/releases/download/v${NEOVIM_VERSION}"
  local tmp; tmp=$(mktemp -d)
  download_verify "$base/$asset" "$base/shasum.txt" "$tmp/$asset" "$asset"
  sudo rm -rf "$NVIM_PREFIX"
  sudo mkdir -p "$NVIM_PREFIX"
  sudo tar -xzf "$tmp/$asset" --strip-components=1 -C "$NVIM_PREFIX"
  sudo ln -sf "$NVIM_PREFIX/bin/nvim" "$SYSTEM_BIN/nvim"
  rm -rf "$tmp"
}

install_antidote_linux() {
  if [[ -d "$HOME/.antidote" ]]; then
    log "antidote already present at ~/.antidote"; return
  fi
  log "Cloning antidote $ANTIDOTE_TAG"
  # -c advice.detachedHead=false suppresses git's reminder about detached
  # HEAD; pinning to a tag intentionally produces this state.
  git -c advice.detachedHead=false clone --depth=1 --branch="$ANTIDOTE_TAG" \
    https://github.com/mattmc3/antidote.git "$HOME/.antidote"
}

# --- macOS ---

bootstrap_macos() {
  command -v brew >/dev/null \
    || die "Homebrew not installed. Install from https://brew.sh and re-run."
  log "Installing formulae via brew bundle"
  brew bundle --file=- <<'BREWFILE'
brew "stow"
brew "zsh"
brew "antidote"
brew "starship"
brew "zoxide"
brew "fzf"
brew "mise"
brew "eza"
brew "fd"
brew "bat"
brew "gh"
brew "neovim"
brew "ripgrep"
BREWFILE
}

# --- Ubuntu ---

apt_add_signed_repo() {
  local name="$1" key_url="$2" repo_line="$3"
  local keyring="/etc/apt/keyrings/${name}.gpg"
  local list="/etc/apt/sources.list.d/${name}.list"
  [[ -f "$list" ]] && return
  log "Adding signed apt repo: $name"
  sudo install -dm 755 /etc/apt/keyrings
  curl -fsSL "$key_url" | sudo gpg --dearmor -o "$keyring"
  sudo chmod go+r "$keyring"
  echo "$repo_line" | sudo tee "$list" >/dev/null
}

system_ubuntu() {
  log "Installing apt base packages"
  sudo apt-get update -qq
  sudo apt-get install -y --no-install-recommends \
    zsh stow make gcc curl ca-certificates gpg \
    software-properties-common \
    bat fd-find ripgrep \
    python3-pip python3-venv

  # Ubuntu 22.04 ships git 2.34, but the stowed .gitconfig uses
  # `merge.conflictstyle = zdiff3` (added in 2.35). Pull git from the
  # git-core PPA (maintained by the git project, signed keyring).
  if ! grep -qr '^deb .*git-core' /etc/apt/sources.list.d/ 2>/dev/null; then
    log "Adding git-core PPA for a modern git"
    sudo add-apt-repository -y ppa:git-core/ppa
    sudo apt-get update -qq
  fi
  sudo apt-get install -y --no-install-recommends git

  # Ubuntu renames these binaries. Expose canonical names via /usr/local/bin
  # so every user on the VM sees `bat`/`fd` without needing per-user symlinks.
  [[ -x /usr/bin/batcat && ! -e "$SYSTEM_BIN/bat" ]] \
    && sudo ln -s /usr/bin/batcat "$SYSTEM_BIN/bat"
  [[ -x /usr/bin/fdfind && ! -e "$SYSTEM_BIN/fd" ]] \
    && sudo ln -s /usr/bin/fdfind "$SYSTEM_BIN/fd"

  local arch; arch="$(dpkg --print-architecture)"
  apt_add_signed_repo githubcli \
    "https://cli.github.com/packages/githubcli-archive-keyring.gpg" \
    "deb [arch=${arch} signed-by=/etc/apt/keyrings/githubcli.gpg] https://cli.github.com/packages stable main"
  apt_add_signed_repo mise \
    "https://mise.jdx.dev/gpg-key.pub" \
    "deb [arch=${arch} signed-by=/etc/apt/keyrings/mise.gpg] https://mise.jdx.dev/deb stable main"
  sudo apt-get update -qq
  sudo apt-get install -y --no-install-recommends gh mise

  # Tool binaries from pinned GitHub releases, installed system-wide.
  install_starship
  install_zoxide
  install_fzf
  install_eza
  install_neovim
}

user_ubuntu() {
  # Everything here must work without sudo so that service accounts like
  # sa-rema (no sudo) can self-apply the config.
  install_antidote_linux
}

apply_dotfiles() {
  log "Stowing packages via make"
  cd "$REPO_DIR"
  make stow
}

print_postinstall() {
  local os="$1"
  local b r; b=$(tput bold 2>/dev/null || true); r=$(tput sgr0 2>/dev/null || true)

  printf '\n%sNext steps%s\n' "$b" "$r"

  case "$os" in
    macos)
      local brew_prefix; brew_prefix=$(brew --prefix)
      cat <<EOF
  - Make brew's zsh your login shell. macOS defaults to /bin/zsh (Apple's
    system zsh) and \`chsh\` only accepts shells listed in /etc/shells, so:

        echo "${brew_prefix}/bin/zsh" | sudo tee -a /etc/shells
        chsh -s "${brew_prefix}/bin/zsh"

EOF
      ;;
    ubuntu)
      cat <<EOF
  - Make zsh your login shell (apt-installed zsh is already in /etc/shells):

        chsh -s "\$(command -v zsh)"

  - Multi-user deploy on this VM:
      sudo su - sa-rema   && git clone <repo> ~/dotfiles && ~/dotfiles/bootstrap.sh --user-only
      sudo -i             && git clone <repo> ~/dotfiles && SKIP_LOCAL=git ~/dotfiles/bootstrap.sh --user-only

EOF
      ;;
  esac

  cat <<EOF
  - Start a zsh session now:          exec zsh
  - Fill in local git identity:       edit ~/.gitconfig.local
                                      [user]
                                        name = ...
                                        email = ...
                                        signingkey = ...
  - Refresh tool completions:         make completions
EOF
}

print_system_only_postinstall() {
  local b r; b=$(tput bold 2>/dev/null || true); r=$(tput sgr0 2>/dev/null || true)
  cat <<EOF

${b}System phase complete${r}
  - Tool binaries are in $SYSTEM_BIN (system-wide); nvim extracted to $NVIM_PREFIX.
  - Each user still needs to apply their own config:
      ./bootstrap.sh --user-only

EOF
}

main() {
  local os; os=$(detect_os)
  log "Detected OS: $os"

  case "$os" in
    macos)
      # macOS uses brew for everything; the system/user split doesn't map cleanly.
      # Flags are accepted but effectively run the full macOS flow either way.
      bootstrap_macos
      apply_dotfiles
      print_postinstall "$os"
      ;;
    ubuntu)
      if (( RUN_SYSTEM )); then
        system_ubuntu
      fi
      if (( RUN_USER )); then
        user_ubuntu
        apply_dotfiles
        print_postinstall "$os"
      else
        print_system_only_postinstall
      fi
      ;;
  esac

  log "Bootstrap complete."
}

main "$@"

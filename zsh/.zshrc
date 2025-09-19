# Load zprof for profiling (keep at top if you intend to profile the whole file)
#zmodload zsh/zprof

# --- Zsh Completion Setup (Optimized for Daily Cache Rebuild) ---
# All `fpath` modifications MUST happen BEFORE compinit.
fpath=(~/.zsh/completions /Users/cle126/.docker/completions ~/.zfunc $fpath)
fpath=(~/.zsh/functions $fpath)
autoload -Uz git-aliases

# Path to the zcompdump file
ZCOMPDUMP="${ZDOTDIR:-$HOME}/.zcompdump"

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# This ensures your prompt appears quickly even before the rest of zshrc loads.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Ignore duplicates
setopt HIST_IGNORE_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FIND_NO_DUPS

# --- OH-MY-ZSH OPTIMIZATIONS (NEW ADDITIONS) ---
# Disable Oh My Zsh auto-updates to save startup time
DISABLE_AUTO_UPDATE="true"

# Set theme (Oh My Zsh will source it based on this variable)
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugin settings - List all plugins here
plugins=(
  docker
  docker-compose
  gh
  git
  golang
  helm
  kubectl
  minikube
  zsh-autosuggestions
  zsh-syntax-highlighting
)

# Load oh-my-zsh (MUST be sourced only once)
source "$ZSH/oh-my-zsh.sh"

# --- User Configuration Starts Here ---

# Set up common paths
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
export JAVA_HOME=$(/usr/libexec/java_home)

# --- Tool Version Managers (Mise) ---
# Mise activation (ONLY ONCE)
eval "$(mise activate zsh)"

# Go Path (Added back - necessary for Go binaries outside of mise's direct management)
export PATH="$PATH:$(go env GOPATH)/bin"

# Source additional scripts/configs
source <(fzf --zsh) # fzf init

# Google Cloud SDK setup
if [ -f '/Users/cle126/Developer/google.cloud/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/cle126/Developer/google.cloud/google-cloud-sdk/path.zsh.inc'; fi
if [ -f '/Users/cle126/Developer/google.cloud/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/cle126/Developer/google.cloud/google-cloud-sdk/completion.zsh.inc'; fi

# --- Powerlevel10k Configuration ---
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# --- Zsh Autosuggestions Optimization ---
export ZSH_AUTOSUGGEST_DEBOUNCE_TIME=50 # milliseconds. Adjust as needed.
export ZSH_AUTOSUGGEST_USE_ASYNC="true"

# --- Other Custom Scripts and Settings ---
source /Users/cle126/.config/op/plugins.sh

# --- Custom functions and aliases ---
alias cat=bat

# ZSH
alias zshrc="nvim ~/.zshrc"
alias zshrcs="source ~/.zshrc"

# Eza
alias l="eza -l --icons --git -a"
alias lt="eza --tree --level=2 --long --icons --git"
alias ltree="eza --tree --level=2  --icons --git"

# LLM
alias ol="ollama run llama3.1"

# Pipx and Cargo paths
export PATH="$PATH:/Users/cle126/.local/bin"
export PATH="$PATH:/Users/cle126/.cargo/bin"

# Fabric bootstrap
if [ -f "/Users/cle126/.config/fabric/fabric-bootstrap.inc" ]; then . "/Users/cle126/.config/fabric/fabric-bootstrap.inc"; fi

# Thefuck alias
eval $(thefuck --alias)

# Zoxide
eval "$(zoxide init zsh)"

# PostgreSQL paths
export PATH="/opt/homebrew/opt/postgresql@16/bin:$PATH"
export LDFLAGS="-L/opt/homebrew/opt/postgresql@16/lib"
export CPPFLAGS="-I/opt/homebrew/opt/postgresql@16/include"

# Go
export PATH="$PATH:$(go env GOPATH)/bin"

# Zsh completion style
zstyle ':completion:*' menu select

# Run zprof to output profiling data
#zprof
# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/cle126/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions

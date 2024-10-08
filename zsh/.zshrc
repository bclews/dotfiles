# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Load oh-my-zsh
source $ZSH/oh-my-zsh.sh

# Set theme
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugin settings
plugins=(gh git docker docker-compose kubectl golang minikube helm zsh-autosuggestions zsh-syntax-highlighting)

# Source oh-my-zsh
source $ZSH/oh-my-zsh.sh

# User configuration

# Set up paths
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
export JAVA_HOME=$(/usr/libexec/java_home)
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH:$(go env GOPATH)/bin"

# Initialize pyenv
eval "$(pyenv init -)"
pyenv global 3.10.0

# Source additional scripts
source ~/powerlevel10k/powerlevel10k.zsh-theme
source <(fzf --zsh)

# Source custom completion scripts
fpath=(~/.zsh/completions $fpath)
autoload -Uz compinit
compinit -i

# Source Powerlevel10k configuration
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Source other custom scripts and settings
source /Users/cle126/.config/op/plugins.sh

# Google Cloud SDK setup
if [ -f '/Users/cle126/Developer/google.cloud/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/cle126/Developer/google.cloud/google-cloud-sdk/path.zsh.inc'; fi
if [ -f '/Users/cle126/Developer/google.cloud/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/cle126/Developer/google.cloud/google-cloud-sdk/completion.zsh.inc'; fi

# Custom functions and aliases
alias vim="nvim"
alias zshrc="vim ~/.zshrc"
alias zshrcs="source ~/.zshrc"
alias vimrc="vim ~/.config/nvim"
alias ls="colorls"
alias ol="ollama run llama3.1"
alias gpt="sgpt --model azure/omni"

# Set up Azure API credentials
# export AZURE_API_KEY=$(op item get gpt-4o --vault CSIRO --fields credential --reveal)
# export AZURE_API_VERSION=$(op item get gpt-4o --vault CSIRO --fields api-version)
# export AZURE_API_BASE=$(op item get gpt-4o --vault CSIRO --fields base-url)

# Ensure Powerlevel10k configuration is sourced correctly
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

zstyle ':completion:*' menu select
fpath+=~/.zfunc

# Created by `pipx` on 2024-07-02 05:59:47
export PATH="$PATH:/Users/cle126/.local/bin"
export PATH="$PATH:/Users/cle126/.cargo/bin"

if [ -f "/Users/cle126/.config/fabric/fabric-bootstrap.inc" ]; then . "/Users/cle126/.config/fabric/fabric-bootstrap.inc"; fi

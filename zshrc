# =============================================================================
# OH-MY-ZSH CONFIGURATION
# =============================================================================

# Path to your oh-my-zsh installation
export ZSH=/Users/wusher/.oh-my-zsh

# Theme configuration
ZSH_THEME="intheloop" # shows computer name

# Shell options
DISABLE_AUTO_TITLE="true"
DISABLE_UNTRACKED_FILES_DIRTY="true"

# History configuration
HISTSIZE=50000
SAVEHIST=50000
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS
setopt SHARE_HISTORY

# Plugins
plugins=()

source $ZSH/oh-my-zsh.sh

# =============================================================================
# PATH CONFIGURATION
# =============================================================================

# Add ~/bin to PATH
PATH=~/bin:$PATH

# Add tailscale to PATH
PATH=/usr/local/bin/tailscale:$PATH

# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# =============================================================================
# DEVELOPMENT TOOLS
# =============================================================================

# Ruby (rbenv)
# eval "$(rbenv init -)"

# Node.js (nvm) - Homebrew version only
#export NVM_DIR="$HOME/.nvm"
#[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
#[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"



# =============================================================================
# ENVIRONMENT VARIABLES
# =============================================================================

export EDITOR=vim
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES

# =============================================================================
# ALIASES
# =============================================================================

# Vim aliases
alias vim='mvim -v'
alias vi='mvim -v'

# Bundle exec shortcuts
alias be="bundle exec"
alias ber="bundle exec rspec"
alias bes="bundle exec spring"
alias besr="bundle exec spring rspec"

# Claude CLI

# Node version switching
alias nv='nvm use `cat .node-version`'


export PATH="/usr/local/bin:$PATH"
eval "$(mise activate zsh)"

# opencode
export PATH=/Users/wusher/.opencode/bin:$PATH

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/wusher/.lmstudio/bin"
# End of LM Studio CLI section



export PATH="$HOME/.local/bin:$PATH"


export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH="/opt/homebrew/opt/openjdk@17/bin:$PATH"

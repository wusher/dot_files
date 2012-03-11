
#bashth to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh



PATH=/Developer/usr/bin:$PATH
PATH=/usr/local/bin:$PATH
PATH=/usr/texbin:$PATH
PATH=/usr/local/mysql/bin:$PATH

alias path='echo -e ${PATH//:/\\n}'
alias gvim=mvim
alias raket='rake environment RAILS_ENV=test '
alias wip='rake cucumber:wip'
alias ctt='ct thredUP3'
alias vim='mvim -v'
alias vi='mvim -v'
alias gsp='git smart-pull'
alias gsm='git smart-merge'
alias gsl='git smart-log'
alias chromedebug='/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --disable-web-security'

export EDITOR='mvim -v'

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
#ZSH_THEME="robbyrussell"
#ZSH_THEME="gallois"
ZSH_THEME="mine"

# Set to this to use case-sensitive completion
# CASE_SENSITIVE="true"

# Comment this out to disable weekly auto-update checks
# DISABLE_AUTO_UPDATE="true"

# Uncomment following line if you want to disable colors in ls
DISABLE_LS_COLORS="true"

# Uncomment following line if you want to disable autosetting terminal title.
DISABLE_AUTO_TITLE="true"

# Uncomment following line if you want red dots to be displayed while waiting for completion
COMPLETION_WAITING_DOTS="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(mine git rvm ruby brew bundler )

source $ZSH/oh-my-zsh.sh

# Customize to your needs...
# RVM
[[ -s '/Users/maudite/.rvm/scripts/rvm' ]] && source '/Users/maudite/.rvm/scripts/rvm'

# RVM
[[ -s '/Users/maudite/.rvm/scripts/rvm' ]] && source '/Users/maudite/.rvm/scripts/rvm'

#tmuxinator
[[ -s $HOME/.tmuxinator/scripts/tmuxinator ]] && source $HOME/.tmuxinator/scripts/tmuxinator


alias ".."="cd .."

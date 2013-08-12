
#bashth to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh



PATH=/Developer/usr/bin:$PATH
PATH=/usr/local/bin:$PATH
PATH=/usr/local/sbin:$PATH
PATH=/usr/texbin:$PATH
PATH=/usr/local/mysql/bin:$PATH
PATH=~/bin:$PATH

PYTHONPATH="/usr/local/lib/python2.7/site-packages:$PYTHONPATH"

alias path='echo -e ${PATH//:/\\n}'
alias raket='rake RAILS_ENV=test '
alias wip='rake cucumber:wip'
alias ctt='cw tup/thredUP3/'
alias cde='cw tup-erp/'
alias cdo='cw tup-ops/'
alias cdp='cw tup-photos/'
alias cdw='cw WarehouseProcessing/'
alias gsp='git smart-pull'
alias gsm='git smart-merge'
alias gsl='git smart-log'
alias chromedebug='/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --disable-web-security'
alias 'unicorn start'=unicorn_rails 
alias 'nopry'=' grep -Ev "IRB = Pry" config/environments/development.rb > tmp.rb && mv tmp.rb config/environments/development.rb'
alias 'fubar'=' grep -Ev "format documentation" .rspec > tmp_file && mv tmp_file .rspec && echo "\n--format Fuubar" >> .rspec'
alias zload="source ~/.zshrc"
alias z="zeus "
alias zake="zeus rake "


#rmagick fixes 
#export MAGICK_HOME=/usr/local/Cellar/imagemagick/6.7.7-6
#export PATH=/usr/local/Cellar/imagemagick/6.7.7-6/include/ImageMagick/wand:$PATH
#export PATH=/usr/local/Cellar/imagemagick/6.7.7-6/include/ImageMagick/magick:$PATH
#export MAGICK_HOME=/usr/local/Cellar/imagemaick/6.8.0-10/lib
export PATH=/usr/local/Cellar/imagemagick/6.8.0-10/lib:$PATH
export PATH=/usr/local/Cellar/imagemagick/6.8.0-10/include/ImageMagick/wand:$PATH
export PATH=/usr/local/Cellar/imagemagick/6.8.0-10/include/ImageMagick/magick:$PATH
export PATH=/Library/Frameworks/Python.framework/Versions/Current/bin:$PATH
export PATH=/usr/local/share/npm/bin:$PATH
#export PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/usr/X11/bin:/usr/local/git/bin:/usr/local/ImageMagick-6.7.1/bin:$PATH
#export DYLD_LIBRARY_PATH=/usr/local/ImageMagick-6.7.1/lib

# lsof -wni tcp:8090"
export EDITOR='mvim -v'

# Enable Ctrl-x-e to edit command line
autoload -U edit-command-line
# Emacs style
zle -N edit-command-line
bindkey '^xe' edit-command-line
bindkey '^x^e' edit-command-line


#everything is vim!!!
set -o vi 

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
DISABLE_LS_COLORS="false"

# Uncomment following line if you want to disable autosetting terminal title.
DISABLE_AUTO_TITLE="true"

# Uncomment following line if you want red dots to be displayed while waiting for completion
COMPLETION_WAITING_DOTS="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(mine git brew cp brew themes  ) #bundler  rvm

source $ZSH/oh-my-zsh.sh

# enable auto-write for vim in tmux 
#source ~/.vim/bundle/tmux-config/tmux-autowrite/autowrite-vim.sh

# Customize to your needs...
# RVM
[[ -s $HOME/.rvm/scripts/rvm ]] && source $HOME/.rvm/scripts/rvm


#tmuxinator
[[ -s $HOME/.tmuxinator/scripts/tmuxinator ]] && source $HOME/.tmuxinator/scripts/tmuxinator


function resetData {
  sudo mysql --execute="CREATE DATABASE ${1:-operations_development}"
  gzip -d ./tmp/thredup.sql.gz
  sudo mysql ${1:-operations_development} < ${2:-./tmp/thredup.sql}
}
  

alias ".."="cd .."
alias vim="mvim -v "

function deploy {
  cap single deploy -s tag=${1}
}

source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

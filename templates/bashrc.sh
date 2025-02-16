eval $(keychain --eval --agents ssh --quiet)

export PATH=$PATH:/usr/local/bin/

##############
# ALIAS 

if [[ $OSTYPE != 'darwin'* ]]; then
  alias bat="batcat"
fi

alias sagent="eval \`ssh-agent -s\`; ssh-add"

alias gitlog="git log --graph --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%an%C(reset)%C(bold yellow)%d%C(reset) %C(dim white)- %s%C(reset)' --all"
alias tmuxkill="tmux kill-session && pkill -f tmux"

# setup an easy way to clear window under tmux
if [[ $TMUX ]]; then
  alias clear='clear && tmux clear-history'
fi

if [ -f "$HOME/Apps/nvim.appimage" ]; then
    alias nvim="$HOME/Apps/nvim.appimage"
fi
alias vi="nvim"
alias vim="nvim"
export EDITOR=$(which nvim) # change the default editor

if [[ $OSTYPE == 'darwin'* ]]; then
  alias chrome="/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome"
  alias google-chrome-stable="chrome"
  alias code="/Applications/Visual\ Studio\ Code.app/Contents/Resources/app/bin/code"
  alias fork="/Applications/Fork.app/Contents/Resources/fork_cli"
fi

###############################################
# Projects

alias iamajoe="cd ~/work/src/github.com/iamajoe"
alias bloggle="cd ~/work/src/github.com/bloggle-app"

if [[ $OSTYPE != 'darwin'* ]]; then
  setxkbmap -option ctrl:nocaps
fi

#####################################
# TMUX

#if [ -z "$TMUX" ]; then
# tmux attach || exec tmux new-session
#fi

#####################################
# Node

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# For compilers to find node@23
if [[ $OSTYPE == 'darwin'* ]]; then
  export LDFLAGS="-L/opt/homebrew/opt/node@23/lib"
  export CPPFLAGS="-I/opt/homebrew/opt/node@23/include"
fi

#####################################
# Go

if [[ $OSTYPE != 'darwin'* ]]; then
  export PATH=$PATH:/usr/local/go/bin
fi
export GOPATH=$HOME/work
export GOBIN=$GOPATH/bin
export PATH="$GOBIN:$PATH"

#####################################
# Zig

if [[ $OSTYPE != 'darwin'* ]]; then
  export PATH=$PATH:/usr/local/bi/
fi

#####################################
# Apps

if [[ $OSTYPE == 'darwin'* ]]; then
  export PATH="$PATH:/Applications/Visual\ Studio\ Code.app/Contents/Resources/app/bin/code/"
  export PATH="$PATH:$HOME/Applications"
fi
if [[ $OSTYPE != 'darwin'* ]]; then
  export PATH="$PATH:$HOME/Apps/"
fi


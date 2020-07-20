#!/usr/local/bin/zsh

# custom variable to denote macOS or linux system
export _OSTYPE="$(uname -s | tr '[:upper:]' '[:lower:]')"

# initial timer for loading .zshrc
timer=$(($(print -P %D{%s%6.})/1000))


# export Homebrew configs
source ~/.config/shellrc.d/homebrew.sh

# set PATH and MANPATH
source ~/.config/shellrc.d/path.sh

# general settings
source ~/.config/shellrc.d/options.zsh

# alias definitions
source ~/.config/shellrc.d/alias.sh
source ~/.config/shellrc.d/alias.zsh

# shell functions
source ~/.config/shellrc.d/functions.sh

# environment settings
source ~/.config/shellrc.d/environment.sh

# keybindings
source ~/.config/shellrc.d/keybindings.zsh

# command history settings
source ~/.config/shellrc.d/history.zsh

# completions
source ~/.config/shellrc.d/completions.zsh

# load ssh keys
source ~/.config/shellrc.d/keychain.sh

# setup prompt
source ~/.config/shellrc.d/prompt.zsh


# start tmux on remote connections
if [[ -n "$SSH_CONNECTION" ]]; then
  if ! tmux has -t main &> /dev/null
  then tmux new -s main
  else tmux attach -t main
  fi
fi

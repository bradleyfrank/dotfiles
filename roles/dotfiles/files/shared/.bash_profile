#!/bin/bash

# custom variable to denote macOS or linux system
export _OSTYPE="$(uname -s | tr '[:upper:]' '[:lower:]')"


# export Homebrew configs
source ~/.config/shellrc.d/homebrew.sh

# set PATH and MANPATH
source ~/.config/shellrc.d/path.sh


# start tmux on remote connections
if [[ -n "$SSH_CONNECTION" ]]; then
  if ! tmux has -t main &> /dev/null
  then tmux new -s main
  else tmux attach -t main
  fi
fi


# source local bashrc
source "$HOME"/.bashrc

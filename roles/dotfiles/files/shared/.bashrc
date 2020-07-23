#!/bin/bash

# skip if not running interactively
[[ $- != *i* ]] && return

# general settings
source ~/.config/shellrc.d/options.bash

# alias definitions
source ~/.config/shellrc.d/alias.sh

# shell functions
source ~/.config/shellrc.d/functions.sh

# environment settings
source ~/.config/shellrc.d/environment.sh

# keybindings
source ~/.config/shellrc.d/keybindings.bash

# load ssh keys
source ~/.config/shellrc.d/keychain.sh

# setup prompt
source ~/.config/shellrc.d/prompt.bash
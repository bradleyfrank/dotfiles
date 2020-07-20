#!/bin/bash

function __prompt_command() {
  local ret=$? \
      reset="\[\e[0;0m\]" \
       bold="\[\e[1m\]" \
       blue="\[\e[38;5;33m\]" \
       cyan="\[\e[38;5;37m\]" \
      green="\[\e[38;5;64m\]" \
    magenta="\[\e[38;5;125m\]" \
        red="\[\e[38;5;160m\]" \
     orange="\[\e[38;5;166m\]"

  _CWD="in ${blue}\W${reset}" _HOST="" _PYENV="" _PROMPT=""

  GIT_PS1_SHOWDIRTYSTATE=true
  GIT_PS1_SHOWSTASHSTATE=true
  GIT_PS1_SHOWUNTRACKEDFILES=true
  GIT_PS1_SHOWCOLORHINTS=true
  GIT_PS1_SHOWUPSTREAM="verbose name"

  [[ -n "$SSH_CONNECTION" && -z "$TMUX" ]] && _HOST="${orange}%m${reset}:"
  [[ -n "$VIRTUAL_ENV" ]] && _PYENV=" ❲${cyan}$(basename "$VIRTUAL_ENV")${reset}❳"
  [[ -n "$CONDA_DEFAULT_ENV" ]] && _PYENV=" ❲${cyan}${CONDA_DEFAULT_ENV}${reset}❳"

  case "$ret" in
    0) _PROMPT="${bold}${green} $ ${reset}"   ;;
    1) _PROMPT="${bold}${red} $ ${reset}"     ;;
    *) _PROMPT="${bold}${magenta} $ ${reset}" ;;
  esac

  __git_ps1 "[${_HOST}${_CWD}]" "${_PYENV}${_PROMPT}" " ❲%s❳"
}

source ~/.local/share/git/git-prompt.sh
PROMPT_COMMAND='__prompt_command; history -a'

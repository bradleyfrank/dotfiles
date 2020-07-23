source ~/.local/share/git/git-prompt.sh

function preexec() { timer=$(($(print -P %D{%s%6.})/1000)) ; }

function precmd() {
  local ret=$? reset="%f"
  local blue="%F{33}" cyan="%F{37}" green="%F{64}" magenta="%F{125}" red="%F{160}" orange="%F{166}"

  _CWD="${blue}%1~${reset}" _TIMESTAMP=" ❲${cyan}$(date +%b" "%e" "%T)${reset}❳"
  _HOST="" _PYENV="" _PROMPT="" _ELAPSED=""

  GIT_PS1_SHOWDIRTYSTATE=true
  GIT_PS1_SHOWSTASHSTATE=true
  GIT_PS1_SHOWUNTRACKEDFILES=true
  GIT_PS1_SHOWCOLORHINTS=true
  GIT_PS1_SHOWUPSTREAM="verbose name"

  [[ -n "$SSH_CONNECTION" && -z "$TMUX" ]] && _HOST="${orange}%m${reset}:"
  [[ -n "$VIRTUAL_ENV" ]] && _PYENV=" ❲${cyan}$(basename "$VIRTUAL_ENV")${reset}❳"
  [[ -n "$CONDA_DEFAULT_ENV" ]] && _PYENV=" ❲${cyan}${CONDA_DEFAULT_ENV}${reset}❳"

  case "$ret" in
    0) _PROMPT="%B${green} %# ${reset}%b"   ;;
    1) _PROMPT="%B${red} %# ${reset}%b"     ;;
    *) _PROMPT="%B${magenta} %# ${reset}%b" ;;
  esac

  if [[ -n $timer ]]; then
    local now elapsed hours minutes seconds millisec
    now=$(($(print -P %D{%s%6.})/1000))
    elapsed=$((${now}-${timer}))

    hours="$(printf "%d" $(($elapsed/1000/60/60)))"
    minutes="$(printf "%d" $(($elapsed/1000/60)))"
    seconds="$(printf "%d" $(($elapsed/1000%60)))"
    millisec="$(printf "%d" $(($elapsed%1000)))"

    if [[ "$hours" == "0" ]];    then hours=""    else hours+="h ";    fi
    if [[ "$minutes" == "0" ]];  then minutes=""  else minutes+="m ";  fi
    if [[ "$seconds" == "0" ]];  then seconds=""  else seconds+="s ";  fi
    if [[ "$millisec" == "0" ]]; then millisec="" else millisec+="ms"; fi

    _ELAPSED="${magenta}${hours}${minutes}${seconds}${millisec}${reset}"
    unset timer
  fi

  __git_ps1 "[${_HOST}${_CWD}]" "${_PYENV}${_PROMPT}" " ❲%s❳"
  RPROMPT="${_ELAPSED}${_TIMESTAMP}"
}

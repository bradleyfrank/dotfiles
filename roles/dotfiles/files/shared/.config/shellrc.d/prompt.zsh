source ~/.local/share/git/git-prompt.sh

function precmd() {
  local ret=$? git_cwd=""
  local reset="%f"
  local blue="%F{33}" \
        cyan="%F{37}" \
        violet="%F{61}" \
        green="%F{64}" \
        magenta="%F{125}" \
        red="%F{160}" \
        orange="%F{166}"

  _CWD="${blue}%1~${reset}" _TIMESTAMP=" ❲${orange}$(date +%b" "%e" "%T)${reset}❳"
  _HOST="" _PYENV="" _GIT_PRE="" _GIT_POST=""  _PROMPT=""

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

  if git_cwd="$(git rev-parse --show-toplevel 2> /dev/null)"; then
    _GIT_PRE=" ❲${violet}$(basename "$git_cwd")${reset}|"
    _GIT_POST="❳"
  fi

  __git_ps1 "❲${_HOST}${_CWD}❳${_GIT_PRE}" "${_GIT_POST}${_PYENV}${_PROMPT}" "%s"
  RPROMPT="${_TIMESTAMP}"
}

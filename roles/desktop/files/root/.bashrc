#!/bin/bash

# Load Bash completions
case "$(uname -s)" in
  Darwin) . /usr/local/etc/profile.d/bash_completion.sh ;;
  Linux ) . /etc/profile.d/bash_completion.sh ;;
esac

# Source git-prompt if necessary
_git_prompt="/usr/share/git-core/contrib/completion/git-prompt.sh"
[[ -e "$_git_prompt" ]] && . "$_git_prompt"

[[ -x /usr/bin/lesspipe ]] && eval "$(SHELL=/bin/sh lesspipe)"

alias glances='glances --theme-white'
alias groot='cd $(git rev-parse --show-toplevel)'
alias ll='ls -lAhF --color=auto'
alias lsmnt='mount | column -t'
alias nbl='grep -Erv "(^#|^$)"'
alias proc='ps -e --forest -o pid,ppid,user,cmd'
alias sane='stty sane'
alias wget='wget -c'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

shopt -s checkwinsize
shopt -s cdspell
shopt -s histappend

bind "set completion-ignore-case on"
bind "set completion-map-case on"
bind "set show-all-if-ambiguous on"
bind "set mark-symlinked-directories on"
bind "set visible-stats on"

export HISTFILESIZE=
export HISTSIZE=
export HISTCONTROL="erasedups:ignoreboth:ignorespace"
export HISTIGNORE="&:[ ]*:exit:ls:bg:fg:history:clear"
export HISTTIMEFORMAT='%F %T '

# quick and dirty docker-compose linter
clint() {
  docker-compose -f "$1" config --quiet
}

# decrypt a file using openssl
decrypt() {
  openssl enc -d -aes-256-cbc -in "$1" -out "$1.decrypted"
}

# encrypt a file using openssl
encrypt() {
  openssl enc -aes-256-cbc -salt -in "$1" -out "$1.encrypted"
}

# show website http headers; follow redirects
httptrace() {
  curl -s -L -D - "$1" -o /dev/null -w "%{url_effective}\n"
}

# tar and gzip a given directory
tardir() {
  tar -czf "${1%/}".tar.gz "$1"
}

# youtube-dl wrapper for docker
youtube-dl() {
  if type youtube-dl >/dev/null 2>&1; then
    youtube-dl "$@"
  elif type docker >/dev/null 2>&1; then
    docker pull mikenye/youtube-dl -q
    docker run --rm -i -v $(pwd):/workdir:rw mikenye/youtube-dl "$@"
  else
    echo "youtube-dl not found"
    return 1
  fi
}

__root_ps1() {
  local ret=$? err="" reset="\[\e[0;0m\]"
  local blue="\[\e[38;5;33m\]" red="\[\e[38;5;160m\]" orange="\[\e[38;5;208m\]"
  _user="${red}\u${reset}" _host="${orange}\h${reset}" _cwd="${blue}\W${reset}"
  [[ $ret -gt 0 ]] && err="${red} ($ret)${reset}"
  __git_ps1 "[${_user}@${_host}:${_cwd}]" "${err}\$ "
  history -a
  history -n
}

GIT_PS1_SHOWDIRTYSTATE=1
GIT_PS1_SHOWSTASHSTATE=1
GIT_PS1_SHOWUNTRACKEDFILES=1
GIT_PS1_SHOWUPSTREAM="auto verbose"
GIT_PS1_SHOWCOLORHINTS=1
PROMPT_COMMAND="__root_ps1"

preexec() {
  timer=$(print -P %D{%s%3.})
}

precmd() {
  local    _rc=$? prompt_color duration_ms duration_s ms s m h
  local -a lprompt_order rprompt_order
  local -A prompt_segments
  local -r base03="%F{234}" \
           blue="%F{33}" \
           cyan="%F{37}" \
           green="%F{64}" \
           magenta="%F{125}" \
           orange="%F{166}" \
           red="%F{160}" \
           violet="%F{61}" \
           yellow="%F{136}" \
           bold="%B" \
           reset="%b%f" \
           eol=$'\n'

  +vi-format() {
    if [[ -s $(git rev-parse --git-common-dir)/refs/stash ]]; then
      hook_com[staged]+="$"
    fi

    if [[ -n ${hook_com[staged]} ]]; then
      hook_com[staged]="${bold}${yellow}${hook_com[staged]}${reset}"
    fi

    if [[ -n ${hook_com[unstaged]} ]]; then
      hook_com[unstaged]="${bold}${yellow}${hook_com[unstaged]}${reset}"
    fi

    if [[ -n ${hook_com[action]} ]]; then
      hook_com[action]="${base03}:${reset}${bold}${red}${hook_com[action]:u}${reset}"
    fi

    hook_com[base-name]="${green}${hook_com[base-name]}${reset}"

    if [[ ${hook_com[subdir]} == "." ]]; then
      hook_com[subdir]=""
    else
      local subdirs subpath numdirs i
      subdirs=( ${(@s:/:)hook_com[subdir]} )
      numdirs=$(( ${#subdirs} - 1 ))
      [[ $numdirs -ge 1 ]] && for i in {1..${numdirs}}; do subpath+="/${subdirs[i][1]}"; done
      subpath+="/${subdirs[-1]}"
      hook_com[subdir]="${subpath}"
    fi

    if [[ -n ${hook_com[staged]} || -n ${hook_com[unstaged]} ]]; then
      hook_com[subdir]+="${base03}:${reset}"
    fi
  }

  vcs_info

  lprompt_order=( venv lbrak cwd host rbrak rc )
  rprompt_order=( clock timer )

  prompt_segments=(
    [venv]=""
    [lbrak]="${base03}[${reset}"
    [cwd]="${bold}${blue}%~${reset}"
    [host]=""
    [rbrak]="${base03}]${reset}"
    [rc]=""
    [clock]="$(date +%r)"
    [timer]=""
  )

  if [[ -n $TMUX ]]; then
    prompt_segments[cwd]="${bold}${blue}%1~${reset}"
  fi

  if [[ -n $vcs_info_msg_0_ ]]; then
    prompt_segments[cwd]="${vcs_info_msg_0_}"
  fi

  if [[ -n $SSH_CONNECTION && -z $TMUX ]]; then
    prompt_segments[host]="${base03}@${reset}${bold}${magenta}%m${reset}"
  fi

  if [[ -n $VIRTUAL_ENV ]]; then
    prompt_segments[venv]="(${bold}${cyan}$(python --version | grep -Po '\d+\.\d+')${reset}) "
  fi

  case "$_rc" in
    0) prompt_color="${green}"   ;;
    1) prompt_color="${red}"     ;;
    *) prompt_color="${magenta}" ;;
  esac

  prompt_segments[rc]="${bold}${prompt_color}%#${reset} "

  if [[ -n $timer ]]; then
    now="$(print -P %D{%s%3.})"
    duration_ms="$(($now - $timer))"
    duration_s="$((duration_ms / 1000))"
    ms="$((duration_ms % 1000))"
    s="$((duration_s % 60))"
    m="$(((duration_s / 60) % 60))"
    h="$((duration_s / 3600))"

    if   [[ $h -gt 0 ]]; then elapsed="${h}h${m}m${s}s"
    elif [[ $m -gt 0 ]]; then elapsed="${m}m${s}.$(printf $(($ms / 100)))s"
    elif [[ $s -gt 9 ]]; then elapsed="${s}.$(printf %02d $(($ms / 10)))s"
    elif [[ $s -gt 0 ]]; then elapsed="${s}.$(printf %03d $ms)s"
    else elapsed="${ms}ms"
    fi

    prompt_segments[timer]=" [${bold}${yellow}${elapsed}${reset}]"
    unset timer
  fi

  PROMPT=""
  for segment in "${lprompt_order[@]}"; do
    PROMPT+="${prompt_segments[${segment}]}"
  done

  RPROMPT=""
  for segment in "${rprompt_order[@]}"; do
    RPROMPT+="${prompt_segments[${segment}]}"
  done
}

zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git*' check-for-changes true
zstyle ':vcs_info:git*' actionformats '%r%S%c%u%a'
zstyle ':vcs_info:git*' formats '%r%S%c%u'
zstyle ':vcs_info:git*+set-message:*' hooks format

precmd() {
  local    _rc=$? prompt_color
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
    local vcs_stash_count vcs_dir_color; vcs_dir_color="$violet"

    if [[ -n ${hook_com[staged]} ]]; then
      hook_com[staged]="${bold}${yellow}${hook_com[staged]}${reset}"
    fi

    if [[ -n ${hook_com[unstaged]} ]]; then
      hook_com[unstaged]="${bold}${yellow}${hook_com[unstaged]}${reset}"
    fi

    if [[ -n ${hook_com[action]} ]]; then
      hook_com[action]="${base03}:${reset}${bold}${red}${hook_com[action]:u}${reset}"
    fi

    if [[ vcs_stash_count="$(git --no-pager stash list | wc -l)" -gt 0 ]]; then
      hook_com[misc]="${base03}:${reset}${bold}${yellow}s${vcs_stash_count}${reset}"
    fi

    if [[ "$(pwd -P)" == */Development/Projects* ]]; then
      vcs_dir_color="$green"
    fi

    hook_com[base-name]="${bold}${vcs_dir_color}${hook_com[base-name]}${reset}"

    if [[ "${hook_com[subdir]}" == "." ]]; then
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
  rprompt_order=( )

  prompt_segments=(
    [venv]=""
    [lbrak]="${base03}[${reset}"
    [cwd]="${bold}${blue}%~${reset}"
    [host]=""
    [rbrak]="${base03}]${reset}"
    [rc]=""
    [clock]=""
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
zstyle ':vcs_info:git*' actionformats '%r%S%c%u%a%m'
zstyle ':vcs_info:git*' formats '%r%S%c%u%m'
zstyle ':vcs_info:git*+set-message:*' hooks format

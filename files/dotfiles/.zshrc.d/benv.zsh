venv_get_project_dir() {
  local git_toplevel md5 venv_project; venv_project="$(pwd)"
  git_toplevel="$(git rev-parse --show-toplevel 2> /dev/null)" && venv_project="$git_toplevel"
  md5="$(md5sum <<< "$venv_project" | awk '{print $1}')"
  print "${HOME}/.local/share/venvs/${md5}"
}


venv_msg() {
  local -r base03="%F{234}" cyan="%F{37}" yellow="%F{136}" blue="%F{33}" reset="%f"
  local msg venv project; msg="$1" venv="$2" project="$3"
  venv="$(dirname "$venv")/$(basename "$venv" | cut -b 1-4)…"
  print -P \
    "${base03}==>${yellow} ${msg}${reset} -> ${cyan}${venv/$HOME/~}${reset} :: ${blue}${project/$HOME/~}"
}


venv_activate() {
  [[ -z $VIRTUAL_ENV_PROJECT ]] && export "$(venv_get_project_dir)"
  [[ ! -d "$VIRTUAL_ENV_PROJECT" ]] && venv_create "$@"
  venv_msg "activating" "$VIRTUAL_ENV_PROJECT"
  source "${VIRTUAL_ENV_PROJECT}/venv/bin/activate"
}


venv_create() {
  [[ -z $VIRTUAL_ENV_PROJECT ]] && export "$(venv_get_project_dir)"
  if [[ ! -e "$VIRTUAL_ENV_PROJECT" ]]; then
    mkdir --parents "${VIRTUAL_ENV_PROJECT}/venv"
    pushd "$VIRTUAL_ENV_PROJECT" > /dev/null || return 1
    ln -s "$(dirs -lp | tail -n1)" project
    popd > /dev/null || return 1
    venv_msg "creating" "$VIRTUAL_ENV_PROJECT"
    virtualenv --quiet "${VIRTUAL_ENV_PROJECT}/venv" "$@"
  fi
}


venv_sync() {
  local requirements
  [[ -z $VIRTUAL_ENV ]] && venv_activate "$@"
  requirements="$(find . -maxdepth 2 -type f -name 'requirements.txt' -print -quit)"
  venv_msg "syncing" "$VIRTUAL_ENV_PROJECT"
  [[ -z $requirements ]] && return 0
  pip install -r "$requirements" > /dev/null
}


venv_cleanup() {
  local project
  for project in "$HOME"/.local/share/venvs/*; do
    if [[ ! -L "${project}/project" || ! -d "$(realpath -P "${project}/project")" ]]; then
      venv_msg "removing" "${project}" "(missing project)"
      rm -rf "$project"
    fi
  done
}


venv_info() {
  local venv_dir
  venv_dir="$(venv_get_project_dir)"
  [[ ! -d "$venv_dir" ]] && return 1
  venv_msg "virtualenv" "$VIRTUAL_ENV_PROJECT" "$(realpath -P "${VIRTUAL_ENV_PROJECT}/project")"
}


venv_help() {
  local -A options
  options=(
    ['activate|a8']="Activate the virtualenv for the current directory"
    ['deactivate|da8']="Deactivate the virtualenv"
    ['sync|update']=""
    ['clean|cleanup']=""
    ['info']=""
    ['help']="Show this help message"
  )
  for option desc in "${(@kv)options}"; do
    print "  ${option};${desc}"
  done | column -ts ';'
}


venv() {
  local subcmd; subcmd="$1"
  [[ "$#" -ge 1 ]] && shift
  case "$subcmd" in
    a8|activate) venv_activate "$@" ;;
    da8|deactivate) deactivate ;;
    sync|update) venv_sync "$@" ;;
    clean|cleanup) venv_cleanup ;;
    info) venv_info ;;
    *) venv_help ;;
  esac
}


alias a8='venv_activate'
alias da8='deactivate'
alias envin='venv_sync'
alias envout='deactivate'

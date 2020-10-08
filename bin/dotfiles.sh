#!/usr/bin/env bash

SKIP_TAGS="work_only"

create_vault_file() {
  local vaultpw vaultfile="$HOME/.ansible_vault_password"
  [[ -e "$vaultfile" ]] && return 0
  read -r -s -p "Enter vault password: " vaultpw
  printf "%s" "$vaultpw" > "$vaultfile"
  chmod 0400 "$vaultfile"
  unset vaultpw
  printf "\n\n" # insert newlines for readability
}

install_ansible() {
  if type python3 > /dev/null; then
    python3 -m pip install --user ansible
  elif type python > /dev/null; then
    python -m pip install --user ansible
  else
    printf "No Python available to install Ansible." >&2
    exit 1
  fi
}

while getopts ':wh' flag; do
  case "$flag" in
    w) SKIP_TAGS="home_only" ;;
    h) SKIP_TAGS="work_only" ;;
    *) printf "%s\n" "Requires [-w|-h], aborting..." >&2 ; exit 1 ;;
  esac
done

if ! type ansible > /dev/null; then
  install_ansible
fi

create_vault_file

ansible-pull \
  --url https://github.com/bradleyfrank/dotfiles.git \
  --directory ~/.dotfiles \
  --tags dotfiles \
  --skip-tags "$SKIP_TAGS" \
  playbooks/"$(uname -s | tr '[:upper:]' '[:lower:]')".yml

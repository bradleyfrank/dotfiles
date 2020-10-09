#!/usr/bin/env bash

SKIP_TAGS="work_only"

while getopts ':wh' flag; do
  case "$flag" in
    w) SKIP_TAGS="home_only" ;;
    h) SKIP_TAGS="work_only" ;;
    *) echo "Requires [-w|-h], aborting..." >&2 ; exit 1 ;;
  esac
done


if ! type git &> /dev/null; then
  echo "Git is not available, aborting..." >&2
  exit 1
fi


if ! type ansible &> /dev/null; then
  if type python3 &> /dev/null; then python3 -m pip install --user ansible
  elif type python &> /dev/null; then python -m pip install --user ansible
  else echo "No Python available to install Ansible, aborting..." >&2 ; exit 1
  fi
fi


if [[ ! -e "$HOME/.ansible_vault_password" ]]; then
  read -r -s -p "Enter vault password: " vaultpw
  echo "$vaultpw" > "$HOME/.ansible_vault_password"
  chmod 0400 "$HOME/.ansible_vault_password"
  echo
fi


ansible-pull \
  --url https://github.com/bradleyfrank/dotfiles.git \
  --directory ~/.dotfiles \
  --tags dotfiles \
  --skip-tags "$SKIP_TAGS" \
  playbooks/"$(uname -s | tr '[:upper:]' '[:lower:]')".yml

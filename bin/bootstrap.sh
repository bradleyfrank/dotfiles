#!/usr/bin/env bash

# ----- global variables ----- #

ANSIBLE_REPO="https://github.com/bradleyfrank/dotfiles.git"
CHECKOUT="$(mktemp -d)"
SKIP_TAGS="work_only"
SYSTEM_TYPE="$(uname -s | tr '[:upper:]' '[:lower:]')"


# ----- functions ----- #

trap cleanup SIGINT

cleanup() {
  [[ -e "$CHECKOUT" ]] && rm -rf "$CHECKOUT"
  [[ "$SYSTEM_TYPE" == "darwin" ]] && kill "$(pgrep caffeinate)" &> /dev/null
}

create_vault_file() {
  local vaultpw vaultfile="$HOME/.ansible_vault_password"
  [[ -e "$vaultfile" ]] && return 0
  read -r -s -p "Enter vault password: " vaultpw
  printf "%s" "$vaultpw" > "$vaultfile"
  chmod 0400 "$vaultfile"
  unset vaultpw
  printf "\n\n" # insert newlines for readability
}

not_supported() {
  printf "%s\n" "Unsupported OS, aborting..." >&2
  exit 1
}

bootstrap_os() {
  case "$SYSTEM_TYPE" in
    darwin) bootstrap_macos ;;
     linux) bootstrap_linux ;;
         *) not_supported   ;;
  esac
}

bootstrap_macos() {
  local homebrew_url="https://raw.githubusercontent.com/Homebrew/install/master/install.sh"
  (caffeinate -d -i -m -u &)
  softwareupdate --install --all
  [[ ! -x /usr/local/bin/brew ]] && CI=1 /bin/bash -c "$(curl -fsSL "$homebrew_url")"
  [[ ! -x /usr/local/bin/ansible ]] && brew install ansible git
}

bootstrap_linux() {
  case "$(sed -rn 's/^ID="?([a-z]+)"?/\1/p' /etc/os-release)" in
    centos)
      sudo yum clean all
      sudo yum makecache
      sudo yum upgrade -y
      sudo --validate
      sudo yum install -y centos-release-ansible-29
      sudo yum install -y ansible git python38
      sudo yum module enable python38
      ;;
    fedora)
      sudo dnf clean all
      sudo dnf makecache
      sudo dnf upgrade -y
      sudo --validate
      sudo dnf install -y ansible git
      ;;
    ubuntu)
      sudo apt-get clean
      sudo apt-get update
      sudo apt-get upgrade -y
      sudo --validate
      sudo apt-get install -y ansible git
      ;;
    *) not_supported ;;
  esac
}

pre_ansible_run() {
  git clone "$ANSIBLE_REPO" "$CHECKOUT"
  ansible-galaxy role install --role-file "$CHECKOUT"/requirements.yml
  ansible-galaxy collection install --requirements-file "$CHECKOUT"/requirements.yml
}

ansible_run() {
  cd "$CHECKOUT" || return 1
  if ansible-playbook \
    --skip-tags "$SKIP_TAGS" \
    --ask-become-pass \
    playbooks/"$SYSTEM_TYPE".yml
  then
    [[ -e "$HOME"/.dotfiles ]] && rm -rf "$HOME"/.dotfiles
    mv "$CHECKOUT" "$HOME"/.dotfiles
    return 0
  else
    return 1
  fi
}


# ----- begin ----- #

while getopts ':wh' flag; do
  case "$flag" in
    w) SKIP_TAGS="home_only" ;;
    h) SKIP_TAGS="work_only" ;;
    *) printf "%s\n" "Requires [-w|-h], aborting..." >&2 ; exit 1 ;;
  esac
done

sudo --validate
create_vault_file
bootstrap_os
pre_ansible_run
ansible_run

rc=$?
cleanup
exit "$rc"

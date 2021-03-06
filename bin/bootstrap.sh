#!/usr/bin/env bash

# ----- global variables ----- #

ANSIBLE_REPO="https://github.com/bradleyfrank/dotfiles.git"
CHECKOUT="$(mktemp -d)"
SKIP_TAGS="work_only"
SYSTEM_TYPE="$(uname -s | tr '[:upper:]' '[:lower:]')"

case "$SYSTEM_TYPE" in
  darwin) SUDOERS_D="/private/etc/sudoers.d" ;;
   linux) SUDOERS_D="/etc/sudoers.d"         ;;
esac


# ----- functions ----- #

trap cleanup SIGINT

cleanup() {
  [[ -e "$SUDOERS_D_TMP" ]] && sudo rm -f "$SUDOERS_D_TMP"
  [[ -e "$CHECKOUT" ]] && rm -rf "$CHECKOUT"
}

create_tmp_sudoers() {
  [[ -e "$SUDOERS_D_TMP" ]] && sudo rm -rf "$SUDOERS_D_TMP"
  SUDOERS_D_TMP="${SUDOERS_D}/99-ansible-$(date +%F)"
  sudo --validate --prompt "Enter sudo password: " # reset sudo timer for following command
  printf "%s ALL=(ALL) NOPASSWD: ALL\n" "$(id -un)" | sudo VISUAL="tee" visudo -f "$SUDOERS_D_TMP"
  printf "\n\n" # insert newlines for readability
}

create_vault_file() {
  local vaultpw vaultfile="$HOME/.ansible_vault_password"
  [[ -e "$vaultfile" || $SKIP_TAGS == "home_only" ]] && return 0
  read -r -s -p "Enter vault password: " vaultpw
  printf "%s" "$vaultpw" > "$vaultfile"
  chmod 0400 "$vaultfile"
  printf "\n\n" # insert newlines for readability
}

keep_awake() {
  case "$SYSTEM_TYPE" in
    darwin)
      kill "$(pgrep caffeinate)" &> /dev/null
      (caffeinate -d -i -m -u &)
      ;;
    linux)
      dconf write /org/gnome/desktop/session/idle-delay 'uint32 0'
      dconf write /org/gnome/settings-daemon/plugins/power/sleep-inactive-ac-timeout "'nothing'"
      ;;
  esac
}

not_supported() {
  printf "%s\n" "Unsupported OS, aborting..." >&2
  exit 1
}

bootstrap_os() {
  case "$SYSTEM_TYPE" in
    darwin) bootstrap_macos ;;
    linux)  bootstrap_linux ;;
    *)      not_supported   ;;
  esac
}

bootstrap_macos() {
  local homebrew_url="https://raw.githubusercontent.com/Homebrew/install/master/install.sh"
  keep_awake
  softwareupdate --install --all
  [[ ! -x /usr/local/bin/brew ]] && CI=1 /bin/bash -c "$(curl -fsSL "$homebrew_url")"
  brew install ansible git
}

bootstrap_linux() {
  case "$(sed -rn 's/^ID="?([a-z]+)"?/\1/p' /etc/os-release)" in
    centos)
      sudo yum clean all
      sudo yum makecache
      sudo yum upgrade -y
      sudo yum install -y centos-release-ansible-29
      sudo yum install -y ansible git python38
      sudo yum module enable python38
      ;;
    fedora)
      keep_awake
      sudo dnf clean all
      sudo dnf makecache
      sudo dnf upgrade -y
      sudo dnf install -y ansible git
      ;;
    ubuntu)
      keep_awake
      sudo apt-get clean
      sudo apt-get update
      sudo apt-get upgrade -y
      sudo apt-get install -y ansible git
      ;;
    *) not_supported ;;
  esac
}

pre_ansible_run() {
  git clone "$ANSIBLE_REPO" "$CHECKOUT"
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

create_tmp_sudoers
create_vault_file
bootstrap_os
pre_ansible_run
ansible_run

rc=$?
cleanup
exit "$rc"

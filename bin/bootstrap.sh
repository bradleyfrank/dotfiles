#!/usr/bin/env bash

# Set global variables
ANSIBLE_REPO="https://github.com/bradleyfrank/dotfiles.git"
CHECKOUT="$(mktemp -d)"
SKIP_TAGS="work_only"
SYSTEM_TYPE="$(uname -s | tr '[:upper:]' '[:lower:]')"
SUDOERS_D_TMP=""


# Perform cleanup on Control-c
trap cleanup SIGINT


cleanup() {
  # cleanup temp files
  [[ -e "$SUDOERS_D_TMP" ]] && sudo rm -rf "$SUDOERS_D_TMP"
  [[ -e "$CHECKOUT" ]] && rm -rf "$CHECKOUT"
}

create_tmp_sudoers() {
  local tmp_sudoers sudopw
  tmp_sudoers="$(mktemp)"
  SUDOERS_D_TMP="/etc/sudoers.d/$(basename "$tmp_sudoers")"
  read -r -s -p "Enter sudo password: " sudopw
  printf "%s ALL=(ALL) NOPASSWD: ALL" "$(id -un)" > "$tmp_sudoers"
  printf "%s" "$sudopw" | sudo -S cp -f "$tmp_sudoers" "$SUDOERS_D_TMP"
  rm -f "$tmp_sudoers"
  unset sudopw
  printf "\n\n" # insert newlines for readability
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
  homebrew_url="https://raw.githubusercontent.com/Homebrew/install/master/install"
  softwareupdate --install --all
  xcode-select --print-path >/dev/null 2>&1 || xcode-select --install
  [[ ! -x /usr/local/bin/brew ]] && /usr/bin/ruby -e "$(curl -fsSL "$homebrew_url")"
  [[ ! -x /usr/local/bin/ansible ]] && brew install ansible git
}

bootstrap_linux() {
  case "$(sed -rn 's/^ID=([a-z]+)/\1/p' /etc/os-release)" in
    fedora)
      sudo dnf clean all
      sudo dnf makecache
      sudo dnf upgrade -y
      sudo dnf install -y ansible git
      ;;
    ubuntu)
      sudo apt-get clean
      sudo apt-get update
      sudo apt-get upgrade -y
      sudo apt-get install -y ansible git
      ;;
    *) not_supported ;;
  esac
}

run_ansible() {
  if ansible-pull \
    --url "$ANSIBLE_REPO" \
    --directory "$CHECKOUT" \
    --skip-tags "$SKIP_TAGS" \
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
run_ansible

rc=$?
cleanup
exit "$rc"

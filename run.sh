#!/usr/bin/env bash

# Set global variables
ANSIBLE_REPO="https://github.com/bradleyfrank/dotfiles.git"
ANSIBLE_VAULT_FILE="$HOME/.ansible_vault_password"
SKIP_TAGS="work_only"
SUDOERS_FILES="/etc/sudoers.d/tmp_ansible_auth"
SUDOPW=""
SYSTEM_TYPE="$(uname -s | tr '[:upper:]' '[:lower:]')"
VAULTPW=""


# Perform cleanup on Cntl-c and exit
trap cleanup INT EXIT


cleanup() {
  # cleanup temp files
  [[ -e "$SUDOERS_FILES" ]] && rm -rf "$SUDOERS_FILES"
  [[ -e "$tmp_checkout" ]] && rm -rf "$tmp_checkout"
  [[ -e "$tmp_sudoers" ]] && rm -rf "$tmp_sudoers"

  # cleanup temp variables
  [[ -n "$ANSIBLE_REPO" ]] && unset ANSIBLE_REPO
  [[ -n "$SKIP_TAGS" ]] && unset SKIP_TAGS
  [[ -n "$SUDOERS_FILES" ]] && unset SUDOERS_FILES
  [[ -n "$SUDOPW" ]] && unset SUDOPW
  [[ -n "$SYSTEM_TYPE" ]] && unset SYSTEM_TYPE
  [[ -n "$VAULTPW" ]] && unset VAULTPW
}

create_tmp_sudoers() {
  local tmp_sudoers
  tmp_sudoers="$(mktemp)"
  read -r -s -p "Enter sudo password: " SUDOPW
  echo "$(id -un) ALL=(ALL) NOPASSWD: ALL" > "$tmp_sudoers"
  printf "%s" "$SUDOPW" | sudo -S cp -f "$tmp_sudoers" "$SUDOERS_FILES"
  unset SUDOPW
}

create_vault_file() {
  [[ -e "$ANSIBLE_VAULT_FILE" ]] && return 0
  read -r -s -p "Enter vault password: " VAULTPW
  printf "%s" "$VAULTPW" > "$ANSIBLE_VAULT_FILE"
  chmod 0400 "$ANSIBLE_VAULT_FILE"
  unset VAULTPW
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
  if type dnf > /dev/null; then
    sudo dnf clean all
    sudo dnf upgrade -y
    sudo dnf install -y ansible git
  elif type apt > /dev/null; then
    sudo apt-get clean
    sudo apt-get update
    sudo apt-get upgrade -y
    sudo apt-get install -y ansible git
  else
    not_supported
  fi
}

run_ansible() {
  tmp_checkout="$(mktemp -d)"

  if ansible-pull \
    --url "$ANSIBLE_REPO" \
    --directory "$tmp_checkout" \
    --skip-tags "$SKIP_TAGS" \
    playbooks/"$SYSTEM_TYPE".yml
  then
    [[ -e "$HOME"/.dotfiles ]] && rm -rf "$HOME"/.dotfiles
    mv "$tmp_checkout" "$HOME"/.dotfiles
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
    *) printf "%s\n" "Requires [[-w|-h]], aborting..." >&2 ; exit 1 ;;
  esac
done

create_tmp_sudoers
create_vault_file
bootstrap_os
run_ansible

exit $?

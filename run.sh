#!/bin/sh

# Set global variables
SUDOPW=""
VAULTPW=""
SKIP_TAGS="work_only"
SYSTEM_TYPE="$(uname -s | tr '[:upper:]' '[:lower:]')"
ANSIBLE_REPO="https://github.com/bradleyfrank/dotfiles.git"
ANSIBLE_VAULT_FILE="$HOME/.ansible_vault_password"


# Restores echo command in case of Cntl-c
trap "stty echo" INT

# Perform cleanup on exit
trap cleanup EXIT


cleanup() {
  [ -e "$tmp_checkout" ] && rm -rf "$tmp_checkout"
  [ -e "$tmp_json" ] && rm -rf "$tmp_json"
  [ -e "$tmp_script" ] && rm -rf "$tmp_script"
  [ -n "$SUDOPW" ] && unset SUDOPW
  [ -n "$VAULTPW" ] && unset VAULTPW
  [ -n "$SKIP_TAGS" ] && unset SKIP_TAGS
  [ -n "$SYSTEM_TYPE" ] && unset SYSTEM_TYPE
  [ -n "$ANSIBLE_REPO" ] && unset ANSIBLE_REPO
}

create_vault_file() {
  [ -e "$ANSIBLE_VAULT_FILE" ] && return 0

  stty -echo
  printf "Enter vault password: "
  read -r VAULTPW
  stty echo
  printf "\n"

  printf "%s" "$VAULTPW" > "$ANSIBLE_VAULT_FILE"
  chmod 0400 "$ANSIBLE_VAULT_FILE"

  unset VAULTPW
}

enter_sudo_pw() {
  stty -echo
  printf "Enter sudo password: "
  read -r SUDOPW
  stty echo
  printf "\n"
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
  [ ! -x /usr/local/bin/brew ] && /usr/bin/ruby -e "$(curl -fsSL "$homebrew_url")"
  [ ! -x /usr/local/bin/ansible ] && brew install ansible git
}

bootstrap_linux() {
  tmp_script="$(mktemp)"

  if type dnf > /dev/null; then
    printf "dnf clean all >/dev/null\ndnf upgrade -y\ndnf install -y ansible git" > "$tmp_script"
  else
    not_supported
  fi

  chmod 0755 "$tmp_script"

  if ! printf "%s" "$SUDOPW" | sudo -S sh "$tmp_script"; then
    printf "Invalid sudo password."
    exit 1
  fi
}

run_ansible() {
  tmp_checkout="$(mktemp -d)"
  tmp_json="$(mktemp)"

  # Make a file with sudo password to avoid escape quote hell
  printf '{"ansible_become_pass":"%s"}' "$SUDOPW" > "$tmp_json"

  if ansible-pull \
    --url "$ANSIBLE_REPO" \
    --directory "$tmp_checkout" \
    --extra-vars "@$tmp_json" \
    --skip-tags "$SKIP_TAGS" \
    playbooks/"$SYSTEM_TYPE".yml
  then
    [ -e "$HOME"/.dotfiles ] && rm -rf "$HOME"/.dotfiles
    mv "$tmp_checkout" "$HOME"/.dotfiles
    return 0
  else
    printf "%s\n" "Ansible run failed" >&2
    return 1
  fi
}


while getopts ':wh' flag; do
  case "$flag" in
    w) SKIP_TAGS="home_only" ;;
    h) SKIP_TAGS="work_only" ;;
    *) printf "%s\n" "Requires [-w|-h], aborting..." >&2 ; exit 1 ;;
  esac
done

create_vault_file
enter_sudo_pw
bootstrap_os
run_ansible

exit $?
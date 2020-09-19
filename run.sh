#!/bin/sh

# Set global variables
SUDOPW=""
SKIP_TAGS="work_only"
SYSTEM_TYPE="$(uname -s | tr '[:upper:]' '[:lower:]')"
ANSIBLE_REPO="https://github.com/bradleyfrank/dotfiles.git"


# Restores echo command in case of Cntl-c
trap "stty echo" INT

# Perform cleanup on exit
trap cleanup EXIT


cleanup() {
  command rm -rf "$tmp_checkout"
  command rm -rf "$tmp_json"
  unset SUDOPW
  unset SKIP_TAGS
  unset SYSTEM_TYPE
  unset ANSIBLE_REPO
}

enter_sudo_pw() {
  stty -echo
  printf "Password: "
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
    prinf "Invalid sudo password."
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

enter_sudo_pw
bootstrap_os
run_ansible

exit $?
#!/bin/sh

# Set global variables
SUDOPW=""
SKIP_TAGS="work_only"

# Restores echo command on Cntl-c
trap "stty echo" INT

# Remove global variables on exit
trap cleanup EXIT

cleanup() {
  command rm -rf "$tmp_checkout"
  command rm -rf "$tmp_json"
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

bootstrap_macos() {
  homebrew_url="https://raw.githubusercontent.com/Homebrew/install/master/install"
  xcode-select --print-path >/dev/null 2>&1 || xcode-select --install
  [ ! -x /usr/local/bin/brew ] && /usr/bin/ruby -e "$(curl -fsSL "$homebrew_url")"
  [ ! -x /usr/local/bin/ansible ] && brew install ansible git
}

bootstrap_linux() {
  case "$(sed -rn 's/^ID=([a-z]+)/\1/p' /etc/os-release)" in
    fedora) printf "%s" "$SUDOPW" | sudo -S dnf install -y ansible git ;;
         *) not_supported ;;
  esac
}

main() {
  ansible_repo="https://github.com/bradleyfrank/dotfiles.git"
  system_os="$(uname -s | tr '[:upper:]' '[:lower:]')"
  tmp_checkout="$(mktemp -d)"
  tmp_json="$(mktemp)"

  # Prompt user for sudo password
  enter_sudo_pw

  # Bootstrap Ansible itself
  case "$system_os" in
    darwin) bootstrap_macos ;;
     linux) bootstrap_linux ;;
         *) not_supported   ;;
  esac

  # Make a json with sudo password to avoid escape quote hell
  printf '{"ansible_become_pass":"%s"}' "$SUDOPW" > "$tmp_json"

  if ansible-pull \
    --url "$ansible_repo" \
    --directory "$tmp_checkout" \
    --extra-vars "@$tmp_json" \
    --skip-tags "$SKIP_TAGS" \
    playbooks/"$system_os".yml
  then
    [ -e "$HOME"/.dotfiles ] && rm -rf "$HOME"/.dotfiles
    mv "$tmp_checkout" "$HOME"/.dotfiles
    exit 0
  else
    printf "%s\n" "Ansible run failed" >&2
    exit 1
  fi
}

# Parse arguments for home/work deployment
while getopts ':wh' flag; do
  case "${flag}" in
    w) SKIP_TAGS="home_only" ;;
    h) SKIP_TAGS="work_only" ;;
    *) printf "%s\n" "Requires [-w|-h], aborting..." >&2 ; exit 1 ;;
  esac
done

# Workhorse function
main

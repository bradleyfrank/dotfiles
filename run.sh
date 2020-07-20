#!/bin/sh

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
    fedora) sudo dnf install -y ansible git ;;
         *) not_supported ;;
  esac
}

main() {
  ansible_repo="https://github.com/bradleyfrank/bootstraps.git"
  system_os="$(uname -s | tr '[:upper:]' '[:lower:]')"
  tmp_checkout="$(mktemp -d)"

  while getopts ':wh' flag; do
    case "${flag}" in
      w) skip_tags="home_only" ;;
      h) skip_tags="work_only" ;;
      *) printf "%s\n" "Requires [-w|-h], aborting..." >&2 ; exit 1 ;;
    esac
  done

  case "$system_os" in
    darwin) bootstrap_macos ;;
     linux) bootstrap_linux ;;
         *) not_supported   ;;
  esac

  if ansible-pull \
    --url "$ansible_repo" \
    --directory "$tmp_checkout" \
    --ask-become-pass \
    --skip-tags "$skip_tags" \
    playbooks/"$system_os".yml
  then
    [ -e "$HOME"/.dotfiles ] && rm -rf "$HOME"/.dotfiles
    mv "$tmp_checkout" "$HOME"/.dotfiles
    exit 0
  else
    rm -rf "$tmp_checkout"
    printf "%s\n" "Ansible run failed" >&2
    exit 1
  fi
}

main

#!/usr/bin/env bash

SCRIPT="$(mktemp)"
RUN_TYPE="bootstrap"
SKIP_TAGS="work"

while getopts ':bdwh' flag; do
  case "$flag" in
    b) RUN_TYPE="bootstrap" ;;
    d) RUN_TYPE="dotfiles"  ;;
    w) SKIP_TAGS="home"     ;;
    h) SKIP_TAGS="work"     ;;
    *) printf "Unrecognized argument, aborting..." >&2 ; exit 1 ;;
  esac
done

wget https://bradleyfrank.github.io/dotfiles/bin/"$RUN_TYPE".sh -O "$SCRIPT"
if [[ "$SKIP_TAGS" == "work" ]]; then bash "$SCRIPT" -h; else bash "$SCRIPT" -w; fi
rm "$SCRIPT"
exit 0

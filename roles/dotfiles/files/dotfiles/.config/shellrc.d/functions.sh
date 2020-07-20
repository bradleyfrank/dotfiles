# Black formatter for Python
function blackdiff() { black --line-length 100 --diff "$@" | diff-so-fancy ; }

# Quick and dirty docker-compose linter
function clint() { docker-compose -f "$1" config --quiet ; }

# Generate a N length diceware password
function diceware() { keepassxc-cli diceware --words "${1:-5}" | tr " " "-" ; }

# Decrypt a file using openssl
function decrypt() { openssl enc -d -aes-256-cbc -in "$1" -out "$1.decrypted" ; }

# Encrypt a file using openssl
function encrypt() { openssl enc -aes-256-cbc -salt -in "$1" -out "$1.encrypted" ; }

# Find a process by name or pid and show only its group/children
function fproc() {
  local pid
  if [[ "$1" =~ ^[0-9]+$ ]]; then pid="$(ps -o sid= -p "$1")"
  else pid="$(pgrep "$1")"
  fi
  ps --forest -o pid,ppid,user,time,cmd -g "$pid"
}

# Detach gedit from the terminal session and supress output
function gedit() { nohup /usr/bin/gedit "$@" &> /dev/null & }

# Show website http headers; follow redirects
function httptrace() { curl -s -L -D - "$1" -o /dev/null -w "%{url_effective}\n" ; }

# Generate a random password
function mkpasswd() { keepassxc-cli generate -L "${1:-16}" -lUn --exclude-similar ; }

# Generate a diceware passphrase with a numeric section
function numware() {
  local length dice pin
  length="${1:-5}"
  [[ $length -lt 2 ]] && { echo "Segment count must be a higher number." >&2 ; return 1 ; }
  dice="$(keepassxc-cli diceware --words "$((length-1))" | tr " " "-")"
  pin="$(keepassxc-cli generate -L "$length" -n)"
  printf "%s-%s\n" "$dice" "$pin"
}

# Update user Python packages
function pup() { pip_upgrade_outdated -3 --user --verbose ; }

# Run all three Python linters at once
function pylinter() {
  black --line-length 79 --diff "$@" | diff-so-fancy
  pylint "$@"
  pycodestyle "$@"
}

# Generate a SSH key programmatically
function sshgen() {
  local comment password keyfile
  comment="$(id -un)@$(uname -n) on $(date --iso-8601=minute)"
  password="$(keepassxc-cli diceware --words 5 | tr ' ' '-')"
  keyfile="$HOME"/.ssh/id_"${1:-rsa}"
  [[ -e "$keyfile" ]] && keyfile="$HOME"/.ssh/id_"$(date +%s)"
  ssh-keygen -q -t rsa -b 4096 -N "$password" -C "$comment" -f "$keyfile"
  echo "$keyfile : $password"
}

# tar and gzip a given directory
function tardir() { tar -czf "${1%/}".tar.gz "$1" ; }

# View cheat sheet for commands
function cheat() { curl -s "cheat.sh/$1?style=vs" ; }

# Download a streaming video
function ytdl-video() {
  youtube-dl \
    --format "bestvideo+bestaudio[ext=m4a]/bestvideo+bestaudio/best" \
    --merge-output-format mp4 \
    -o "%(title)s.%(ext)s" \'"$1"\'
}

# Download YouTube video as music only
function ytdl-music() {
  if [[ "$_OSTYPE" == "darwin" ]]; then
    youtube-dl --format bestaudio --extract-audio --audio-format mp3 \
      --postprocessor-args "-strict experimental" \'"$1"\'
  else
    youtube-dl --format bestaudio --extract-audio --audio-format mp3 \'"$1"\'
  fi
}
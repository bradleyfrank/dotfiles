PATH=~/.local/bin:~/bin
PATH="$PATH":/usr/local/bin:/usr/local/sbin
PATH="$PATH":/usr/bin:/usr/sbin:/bin:/sbin
MANPATH=~/.local/share/man
MANPATH=/usr/local/share/man:/usr/share/man:"$MANPATH"

if [[ "$_OSTYPE" == "darwin" ]]; then
  # Python 3 binaries
  PATH="$PATH:$HOME/Library/Python/$(python3 -V | grep -Eo '\b[0-9]\.[0-9]')/bin"

  # X11 provided by XQuartz
  PATH="$PATH:/opt/X11/bin"

  # Homebrew MacOS GNU Core Utilities
  if type brew &> /dev/null; then
    PATH="$(brew --prefix)/opt/coreutils/libexec/gnubin:$PATH"
    PATH="$(brew --prefix)/opt/gnu-tar/libexec/gnubin:$PATH"
    PATH="$(brew --prefix)/opt/ed/libexec/gnubin:$PATH"
    PATH="$(brew --prefix)/opt/grep/libexec/gnubin:$PATH"
    PATH="$(brew --prefix)/opt/gnu-sed/libexec/gnubin:$PATH"
    PATH="$(brew --prefix)/opt/gawk/libexec/gnubin:$PATH"
    PATH="$(brew --prefix)/opt/findutils/libexec/gnubin:$PATH"
    MANPATH="$(brew --prefix)/opt/coreutils/libexec/gnuman:$MANPATH"
    MANPATH="$(brew --prefix)/opt/gnu-tar/libexec/gnuman:$MANPATH"
    MANPATH="$(brew --prefix)/opt/ed/libexec/gnuman:$MANPATH"
    MANPATH="$(brew --prefix)/opt/grep/libexec/gnuman:$MANPATH"
    MANPATH="$(brew --prefix)/opt/gnu-sed/libexec/gnuman:$MANPATH"
    MANPATH="$(brew --prefix)/opt/gawk/libexec/gnuman:$MANPATH"
    MANPATH="$(brew --prefix)/opt/findutils/libexec/gnuman:$MANPATH"
  fi
elif [[ "$_OSTYPE" == "linux" ]]; then
  # Homebrew formulas
  type brew &> /dev/null && PATH="$(brew --prefix)/bin:$PATH"
fi

export PATH
export MANPATH
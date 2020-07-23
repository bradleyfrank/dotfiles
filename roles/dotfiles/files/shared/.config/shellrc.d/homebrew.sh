if type brew &> /dev/null; then
  export HOMEBREW_PREFIX="$(brew --prefix)"
  export HOMEBREW_CELLAR="$(brew --prefix)/Cellar"
  export HOMEBREW_REPOSITORY="$(brew --prefix)/Homebrew"
  export INFOPATH="$(brew --prefix)/share/info:${INFOPATH:-}"
fi
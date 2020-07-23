if [[ "$_OSTYPE" == "darwin" ]]; then
  # Workaround a bug in bash-completion@2 2.10
  # https://github.com/scop/bash-completion/issues/374
  # https://github.com/Homebrew/homebrew-core/pull/47527
  export BASH_COMPLETION_COMPAT_DIR="/usr/local/etc/bash_completion.d" 
  source /usr/local/etc/profile.d/bash_completion.sh
else
  source /etc/profile.d/bash_completion.sh
fi

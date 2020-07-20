case "$_OSTYPE" in
  darwin) eval "$(keychain --eval --ignore-missing --quiet --inherit any id_rsa id_develop id_home)" ;;
   linux) eval "$(keychain --eval --ignore-missing --quiet id_rsa id_develop id_home)" ;;
esac


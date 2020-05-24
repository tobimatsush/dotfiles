#!/usr/bin/env bash

DOTFILE_DIR="${DOTFILE_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

main() {
  local branch="$(git rev-parse --abbrev-ref HEAD)"
  if [[ "$branch" != "master" ]]; then
    echo "Warning: current branch not 'master'"
  fi

  read -p "Enter your name: " NAME
  read -p "Enter your email: " EMAIL
  read -p "Enter your GPG key id (leave empty if none): " GPGKEYID

  echo "Patching..."
  patch::git
  patch::gpg

  echo "Registering remote 'upstream'..."
  git remote add upstream https://github.com/midchildan/dotfiles.git

  echo "Complete! You can commit the changes by running:"
  echo "  export GIT_AUTHOR_NAME=\"$NAME\""
  echo "  export GIT_COMMITTER_NAME=\"$NAME\""
  echo "  export EMAIL=\"$EMAIL\""
  echo "  git commit -am 'replace profile information'"
}

patch::git() {
  git::config user.name "$NAME"
  git::config user.email "$EMAIL"
  if [[ -n "$GPGKEYID" ]]; then
    git::config commit.gpgsign true
    git::config user.signingkey "$GPGKEYID"
  else
    git::config --unset-all commit.gpgsign
    git::config --unset-all user.signingkey
  fi
}

patch::gpg() {
  local confpath="$DOTFILE_DIR/home/.gnupg/gpg.conf"

  if [[ -z "$GPGKEYID" ]]; then
    # if no keyid is specified, remove keyid setting
    sed -i -e '/^default-key/d' -e '/./,$!d' "$confpath"
  elif grep -q '^default-key' "$confpath"; then
    # if there's an existing keyid setting, replace it
    sed -i -e "s/^default-key.*/default-key $GPGKEYID/" "$confpath"
  else
    # add keyid setting
    sed -i -e "1 i default-key $GPGKEYID\n" "$confpath"
  fi
}

git::config() {
  git config --file "$DOTFILE_DIR/home/.config/git/config" "$@"
}

main

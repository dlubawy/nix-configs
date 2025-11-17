#!/usr/bin/env bash
SHADOW_FILE="$HOME/.shadow"

trap '' SIGINT

confirm_password() {
  password_hash=$(cat "$SHADOW_FILE")
  read -r -s -p "Current password:" current_password
  echo ""

  password_salt=$(echo "$password_hash" | awk -F'$' '{ printf "%s$%s$%s$%s$", $1, $2, $3, $4 }')
  current_password_hash=$(mkpasswd -S "${password_salt}" "$current_password")

  if [ "$current_password_hash" != "$password_hash" ]; then
    echo "Current password doesn't match" 1>&2
    chmod 0000 "$SHADOW_FILE"
    exit 1
  fi
}

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    -h|--help)
      cat <<HELP
Manages passwords in the user's personal shadow file: "$SHADOW_FILE".

Usage:
  nixos-passwd [FLAGS]

Args:
  -h|--help, this help message

Example:
  nixos-passwd
HELP
      exit 0
      ;;
    *)
      echo "Unknown option $1"
      exit 1
      ;;
  esac
done

if [ ! -d "$HOME" ]; then
  echo "${HOME:-"HOME"} dir does not exist" 1>&2
  exit 1
fi

if [ -f "$SHADOW_FILE" ]; then
  chattr -i "$SHADOW_FILE"
  chmod 0400 "$SHADOW_FILE"
  confirm_password
  mv "$SHADOW_FILE" "$SHADOW_FILE.bak"
fi

set +e
nixos-mkpasswd -f "$SHADOW_FILE"

# shellcheck disable=SC2181
if [ "$?" -eq 0 ] && [ -f "$SHADOW_FILE.bak" ]; then
  set -e
  rm -f "$SHADOW_FILE.bak"
elif [ -f "$SHADOW_FILE.bak" ]; then
  set -e
  mv "$SHADOW_FILE.bak" "$SHADOW_FILE"
fi

if [ -f "$SHADOW_FILE" ]; then
  chattr +i "$SHADOW_FILE"
fi

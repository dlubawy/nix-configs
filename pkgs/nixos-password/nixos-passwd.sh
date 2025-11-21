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
    exit 1
  fi
}

LOCK=""
LOCK_SSH=""
UNLOCK=""

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    -h|--help)
      cat <<HELP
Manages passwords in the user's personal shadow file: "$SHADOW_FILE".

Usage:
  nixos-passwd [FLAGS]

Args:
  -h|--help, this help message
  -l|--lock, lock the password
  -L|--lock-ssh, lock the password and SSH logins

Example:
  nixos-passwd
HELP
      exit 0
      ;;
    -l|--lock)
      LOCK="true"
      shift
      ;;
    -L|--lock-ssh)
      LOCK_SSH="true"
      shift
      ;;
    -u|--unlock)
      UNLOCK="true"
      shift
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
  WORD_COUNT="$(wc -m "$SHADOW_FILE" | awk -F' ' '{ print $1 }')"
  if [ "$WORD_COUNT" -gt 1 ]; then
      confirm_password
  elif [ -z "$UNLOCK" ]; then
      echo "Password is locked" 1>&2
      exit 1
  fi
  chattr -i "$SHADOW_FILE"
fi

if [ -n "$LOCK" ] && [ -z "$LOCK_SSH" ]; then
  echo -n '*' > "$SHADOW_FILE"
elif [ -n "$LOCK_SSH" ]; then
  echo -n '!' > "$SHADOW_FILE"
else
  nixos-mkpasswd -f "$SHADOW_FILE" || true
fi

if [ -f "$SHADOW_FILE" ]; then
  chattr +i "$SHADOW_FILE"
else
  echo "Failed to create $SHADOW_FILE" 1>&2
  exit 1
fi

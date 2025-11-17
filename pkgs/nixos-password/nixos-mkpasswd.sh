POSITIONAL_ARGS=()
PW_FILE="$HOME/.shadow"

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    -h|--help)
      cat <<HELP
Create a new NixOS password hash file if it does not exist.

Wraps mkpasswd to create a new password hash and then writes to a file NixOS can parse with 0000 set using chmod.

Usage:
  nixos-mkpasswd [FLAGS] [PASSWORD]

Args:
  -h|--help, this help message
  -f|--file [FILE], file location to write to (default: "$PW_FILE")

Example:
  nixos-mkpasswd
  nixos-mkpasswd -f "my-password-file"
  nixos-mkpasswd "my-password"
HELP
      exit 0
      ;;
    -f|--file)
      PW_FILE="$2"
      shift 2
      ;;
    -*)
      echo "Unknown option $1"
      exit
      ;;
    *)
      POSITIONAL_ARGS+=("$1")
      shift
      ;;
  esac
done

set -- "${POSITIONAL_ARGS[@]}"

if [ -f "$PW_FILE" ]; then
  echo "File already exists" 1>&2
  exit 1
fi

if [ "${#POSITIONAL_ARGS[@]}" -eq 0 ]; then
  read -r -s -p "Password:" password
  echo ""
  read -r -s -p "Confirm password:" password_check
  echo ""

  if [ "$password" != "$password_check" ]; then
    echo "Passwords do not match!" 1>&2
    exit 1
  fi
else
  password="$1"
fi

mkpasswd "$password" | tr -d '\n' > "$PW_FILE"
chmod 0000 "$PW_FILE"

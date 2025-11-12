{ pkgs, ... }:
pkgs.writeShellApplication {
  name = "nixos-passwd";
  runtimeInputs = with pkgs; [
    mkpasswd
  ];
  text = ''
    POSITIONAL_ARGS=()
    USER_SHADOW="$HOME"/.shadow
    PW_FILE=""

    while [[ "$#" -gt 0 ]]; do
      case "$1" in
        -h|--help)
          cat <<HELP
    Create a new password hash for NixOS.

    Wraps mkpasswd to create a new password hash and then writes to a file with 0000 set using chmod.
    The default file location is $USER_SHADOW and witll be made immutable.

    Usage:
      nixos-passwd [FLAGS] [PASSWORD]

    Args:
      -h|--help, this help message
      -f|--file [FILE], file location to write to (default: "$PW_FILE")

    Example:
      nixos-passwd
      nixos-passwd -f "my-password-file"
      nixos-passwd "my-password"
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

    set -- "''${POSITIONAL_ARGS[@]}"

    if [ "''${#POSITIONAL_ARGS[@]}" -eq 0 ]; then
      read -r -s -p "Password: " password
      echo ""
      read -r -s -p "Confirm password: " password_check
      echo ""

      if [ "$password" != "$password_check" ]; then
        echo "Passwords do not match. Aborting!" 1>&2
        exit 1
      fi
    else
      password="$1"
    fi

    if [ -n "$PW_FILE" ] && [ -f "$PW_FILE" ]; then
      rm -f "$PW_FILE"
    elif [ -z "$PW_FILE" ]; then
      if [ -f "$USER_SHADOW" ]; then
        chattr -i "$USER_SHADOW"
        rm -f "$USER_SHADOW"
      fi
      PW_FILE="$USER_SHADOW"
    fi

    mkpasswd "$password" | tr -d '\n' > "$PW_FILE"
    chmod 0000 "$PW_FILE"

    if [ -f "$USER_SHADOW" ]; then
      chattr +i "$USER_SHADOW"
    fi
  '';
}

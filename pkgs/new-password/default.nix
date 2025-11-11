{ pkgs, ... }:
pkgs.writeShellApplication {
  name = "new_password";
  runtimeInputs = with pkgs; [
    mkpasswd
  ];
  text = ''
    POSITIONAL_ARGS=()
    PW_FILE="$HOME"/.shadow

    while [[ "$#" -gt 0 ]]; do
      case "$1" in
        -h|--help)
          cat <<HELP
    Create a new password hash file using mkpasswd.

    Usage:
      new_password [FLAGS] [PASSWORD]

    Args:
      -h|--help, this help message
      -f|--file [FILE], file location to write to (default: "$PW_FILE")

    Example:
      new_password
      new_password -f my_password_file
      new_password my_password
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

    if [ -f "$PW_FILE" ]; then
      chattr -i "$PW_FILE"
      rm -f "$PW_FILE"
    fi
    mkpasswd "$password" | tr -d '\n' > "$PW_FILE"
    chmod 0000 "$PW_FILE"
    chattr +i "$PW_FILE"
  '';
}

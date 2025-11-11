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

    Args:
      -h|--help, this help message
      -f|--file, file location to write to (default: "$PW_FILE")
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

    read -r -s -p "Password: " password
    echo ""
    read -r -s -p "Confirm password: " password_check
    echo ""

    if [ "$password" != "$password_check" ]; then
      echo "Passwords do not match. Aborting!" 1>&2
      exit 1
    fi

    mkpasswd "$password" | tr -d '\n' > "$PW_FILE"
    chmod 0600 "$PW_FILE"
  '';
}

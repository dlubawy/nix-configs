{ lib, config, ... }:
let
  user = builtins.head (lib.attrValues config.nix-configs.users);
in
{
  programs.git = {
    enable = true;
    userEmail = if user.email == "" then null else user.email;
    userName = if user.fullName == "" then null else user.fullName;
    extraConfig = {
      init = {
        defaultBranch = "main";
      };
    };
    signing = lib.mkIf (user.gpgKey != null) {
      format = "openpgp";
      key = "${user.gpgKey}";
      signByDefault = true;
    };
    ignores = [
      # Direnv
      ".direnv"

      # OS
      ".DS_Store"
      "ehthumbs.db"
      "Icon?"
      "Thumbs.db"

      # Editor
      "*~"
      "*.swp"
      "*.swo"
    ];
  };
}

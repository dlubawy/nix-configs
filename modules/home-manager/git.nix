{ lib, config, ... }:
let
  inherit (lib) mkIf;
  user = builtins.head (lib.attrValues config.nix-configs.users);
in
{
  programs.git = {
    enable = true;
    settings = {
      user = mkIf (user.email != "" && user.fullName != "") {
        email = user.email;
        name = user.fullName;
      };
      extraConfig = {
        init = {
          defaultBranch = "main";
        };
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

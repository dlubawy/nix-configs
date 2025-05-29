{ lib, config, ... }:
let
  user = builtins.head (lib.attrValues config.nix-configs.users);
in
{
  programs.git = {
    enable = true;
    userEmail = (lib.optionalString (user.email != null) "${user.email}");
    userName = (lib.optionalString (user.fullName != null) "${user.fullName}");
    extraConfig = {
      init = {
        defaultBranch = "main";
      };
    };
    signing = lib.mkIf (user.gpgKey != null) {
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

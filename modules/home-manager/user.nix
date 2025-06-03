{
  lib,
  pkgs,
  config,
  ...
}:
let
  nixConfigsUsers = config.nix-configs.users;
  users = lib.attrValues nixConfigsUsers;
in
{
  imports = [
    (import ../nix-configs).default
  ];

  config = {
    assertions = [
      {
        assertion = (builtins.length users == 1);
        message = "A user must be defined and only one user can be defined per home";
      }
    ];

    home =
      let
        user = builtins.head users;
      in
      {
        username = user.name;
        homeDirectory = "/${if pkgs.stdenv.isDarwin then "Users" else "home"}/${user.name}";

        file.".ssh/id_yubikey.pub" = lib.mkIf (user.sshKey != null) {
          enable = true;
          text = user.sshKey;
        };
      };
  };
}

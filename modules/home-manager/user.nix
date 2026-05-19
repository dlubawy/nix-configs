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

        file = lib.mkIf (user.sshKey != null) {
          ".ssh/${user.sshKey.type}_${user.sshKey._algorithm}.pub" = {
            enable = user.sshKey.type == "ssh";
            text = user.sshKey.key;
          };
          ".ssh/yubikey_id.pub" = {
            enable = user.sshKey.type == "yubikey";
            text = user.sshKey.key;
          };
        };
      };
  };
}

{
  lib,
  pkgs,
  config,
  ...
}:
let
  nixConfigsUsers = config.nix-configs.users;
  nixConfigsUsersNames = lib.attrNames nixConfigsUsers;
  username = builtins.head nixConfigsUsersNames;
in
{
  imports = [
    (import ../nix-configs).default
  ];

  config = {
    assertions = [
      {
        assertion = (builtins.length nixConfigsUsersNames == 1);
        message = "Only one user can be defined per home";
      }
    ];

    home = {
      username = "${username}";
      homeDirectory = "/${if pkgs.stdenv.isDarwin then "Users" else "home"}/${username}";

      file.".ssh/id_yubikey.pub" = lib.mkIf (nixConfigsUsers.${username}.sshKey != null) {
        enable = true;
        text = nixConfigsUsers.${username}.sshKey;
      };
    };
  };
}

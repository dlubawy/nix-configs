{
  lib,
  pkgs,
  config,
  ...
}:
let
  nixConfigsUsers = config.nix-configs.users;
in
{
  imports = [
    (import ../nix-configs).default
  ];

  config = {
    users.users = (
      lib.concatMapAttrs (name: value: {
        ${name} = {
          isNormalUser = true;
          shell = pkgs.zsh;
          description = "${value.fullName}";
          extraGroups = [
            "wheel"
            "networkmanager"
          ];
          initialPassword = "${name}";
          openssh.authorizedKeys.keys = [ ] ++ (lib.optionals (value.sshKey != null) [ value.sshKey ]);
        };
      }) nixConfigsUsers
    );
  };
}

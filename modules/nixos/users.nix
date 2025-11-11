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

  environment.systemPackages = with pkgs; [
    new-password
  ];

  config = {
    users.users = (
      lib.concatMapAttrs (name: value: {
        ${name} = {
          name = value.name;
          isNormalUser = true;
          shell = pkgs.zsh;
          description = value.fullName;
          extraGroups = [
            "wheel"
            "networkmanager"
          ];
          initialPassword = if (value.initialHashedPassword == null) then value.name else null;
          initialHashedPassword = value.initialHashedPassword;
          hashedPasswordFile = value.hashedPasswordFile;

          openssh.authorizedKeys.keys = [ ] ++ (lib.optionals (value.sshKey != null) [ value.sshKey ]);
        };
      }) nixConfigsUsers
    );
  };
}

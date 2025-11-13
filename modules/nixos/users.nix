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
    environment.systemPackages = with pkgs; [
      nixos-password
    ];

    security.wrappers.new-password = {
      owner = "root";
      group = "root";
      source = "${pkgs.nixos-password}/bin/nixos-passwd";
      capabilities = "cap_dac_override,cap_linux_immutable+ep";
    };

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
          initialPassword = lib.mkDefault (
            if (value.initialHashedPassword == null) then value.name else null
          );
          initialHashedPassword = lib.mkDefault value.initialHashedPassword;
          hashedPasswordFile = lib.mkDefault value.hashedPasswordFile;

          openssh.authorizedKeys.keys = [ ] ++ (lib.optionals (value.sshKey != null) [ value.sshKey ]);
        };
      }) nixConfigsUsers
    );
  };
}

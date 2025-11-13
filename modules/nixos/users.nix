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

  options = {
    users.shadow.enable = lib.mkEnableOption "Enable individual user shadow file for password hash";
  };

  config = {
    environment.systemPackages = with pkgs; [
      nixos-password
    ];

    security.wrappers.new-password = {
      enable = config.users.shadow.enable;
      owner = "root";
      group = "root";
      source = "${pkgs.nixos-password}/bin/nixos-passwd";
      capabilities = "cap_dac_override,cap_linux_immutable+ep";
    };

    users.users = (
      lib.concatMapAttrs (name: value: {
        ${name} =
          let
            userHome = config.users.users.${name}.home;
          in
          {
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
            hashedPasswordFile =
              if config.users.shadow.enable then
                "${userHome}/.config/nixos/shadow"
              else
                lib.mkDefault value.hashedPasswordFile;

            openssh.authorizedKeys.keys = [ ] ++ (lib.optionals (value.sshKey != null) [ value.sshKey ]);
          };
      }) nixConfigsUsers
    );
  };
}

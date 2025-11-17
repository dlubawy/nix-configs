{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib)
    concatMapAttrs
    attrValues
    filterAttrs
    filter
    length
    getAttr
    hasAttr
    mkDefault
    mkEnableOption
    mkIf
    nameValuePair
    optionals
    mapAttrs'
    ;
  nixConfigsUsers = config.nix-configs.users;
in
{
  imports = [
    (import ../nix-configs).default
  ];

  options = {
    users.shadow.enable = mkEnableOption "Enable individual user shadow file for password hash";
  };

  config = {
    assertions = [
      {
        assertion =
          config.users.shadow.enable
          -> (length (filter (v: v.initialHashedPassword != null) (attrValues config.nix-configs.users)) > 0);
        message = "Users must have an initialHashedPassword set if using nix-configs.shadow";
      }
    ];

    security.wrappers.nixos-passwd = {
      enable = config.users.shadow.enable;
      owner = "root";
      group = "root";
      source = "${pkgs.nixos-password}/bin/nixos-passwd";
      capabilities = "cap_dac_override,cap_linux_immutable+ep";
    };

    systemd.tmpfiles.settings.home-directories = mkIf config.users.shadow.enable (
      mapAttrs'
        (
          username: opts:
          nameValuePair ((toString opts.home) + "/.shadow") {
            f = {
              mode = "0000";
              user = opts.name;
              inherit (opts) group;
              argument = (getAttr opts.name config.nix-configs.users).initialHashedPassword;
            };
          }
        )
        (
          filterAttrs (
            _username: opts:
            opts.enable
            && opts.createHome
            && opts.home != "/var/empty"
            && (hasAttr opts.name config.nix-configs.users)
          ) config.users.users
        )
    );

    users.users = (
      concatMapAttrs (name: value: {
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
            initialPassword = mkDefault (
              if
                (
                  value.initialHashedPassword == null
                  && value.hashedPasswordFile == null
                  && !config.users.shadow.enable
                )
              then
                value.name
              else
                null
            );
            initialHashedPassword = mkDefault (
              if config.users.shadow.enable then
                null
              else
                (if value.hashedPasswordFile == null then value.initialHashedPassword else null)
            );
            hashedPasswordFile = mkDefault (
              if config.users.shadow.enable then "${userHome}/.shadow" else value.hashedPasswordFile
            );

            openssh.authorizedKeys.keys = [ ] ++ (optionals (value.sshKey != null) [ value.sshKey ]);
          };
      }) nixConfigsUsers
    );
  };
}

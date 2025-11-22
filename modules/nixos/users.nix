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
    optionalAttrs
    optionals
    mapAttrs'
    ;
  nixConfigsUsers = config.nix-configs.users;
  hasPersist = builtins.hasAttr "/persist" config.fileSystems;
in
{
  imports = [
    (import ../nix-configs).default
  ];

  options = {
    # Allows using $HOME/.shadow to manage the password hash
    # Makes mutable users work with /etc wipe on every boot (erase your darlings)
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
      {
        assertion =
          (config.users.shadow.enable && hasPersist) -> (config.fileSystems."/persist".neededForBoot);
        message = "`/persist` mount should be enabled in initrd when using user shadow files";
      }
      {
        assertion =
          (config.users.shadow.enable && !hasPersist && (builtins.hasAttr "/home" config.fileSystems))
          -> (config.fileSystems."/home".neededForBoot);
        message = "`/home` mount should be enabled in initrd when using user shadow files and no /persist mount is available";
      }
    ];
    services.userborn.enable = true;

    # Enable to allow chattr for root if needing to remove a file
    environment.systemPackages = with pkgs; [ ] ++ optionals config.users.shadow.enable [ e2fsprogs ];

    # nixos-passwd needs chattr +/-i on user shadow files
    security.wrappers.nixos-passwd = {
      enable = config.users.shadow.enable;
      owner = "root";
      group = "root";
      source = "${pkgs.nixos-password}/bin/nixos-passwd";
      capabilities = "cap_linux_immutable+ep";
    };

    # Create the initial $HOME/.shadow file using an initialHashedPassword
    # Users may then change password using nixos-passwd
    # Should prevent user lockout if .shadow is deleted as it will revert to initialHashedPassword
    systemd.tmpfiles.settings.home-directories = mkIf config.users.shadow.enable (
      mapAttrs'
        (
          username: opts:
          let
            shadowFile = ((toString opts.home) + "/.shadow");
          in
          (
            nameValuePair (if hasPersist then "/persist" + shadowFile else shadowFile) {
              f = {
                mode = "600";
                user = opts.name;
                inherit (opts) group;
                argument = (getAttr opts.name config.nix-configs.users).initialHashedPassword;
              };
              h = {
                argument = "+i";
              };
            }
            // (optionalAttrs hasPersist (
              nameValuePair ("/persist" + (toString opts.home)) {
                d = {
                  mode = opts.homeMode;
                  user = opts.name;
                  inherit (opts) group;
                };
              }
            ))
          )
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
              if config.users.shadow.enable then
                (if hasPersist then "/persist/${userHome}/.shadow" else "${userHome}/.shadow")
              else
                value.hashedPasswordFile
            );

            openssh.authorizedKeys.keys = [ ] ++ (optionals (value.sshKey != null) [ value.sshKey ]);
          };
      }) nixConfigsUsers
    );
  };
}

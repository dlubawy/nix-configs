{ lib, ... }:
let
  inherit (lib)
    mkDefault
    mkMerge
    mkOption
    stringLength
    strings
    types
    ;
  keyAlgorithm = sshKey: builtins.elemAt (strings.split " " (strings.removePrefix "ssh-" sshKey)) 0;
  sshKeyOpts =
    { config, ... }:
    {
      options = {
        type = mkOption {
          type = types.enum [
            "ssh"
            "yubikey"
          ];
          default = "ssh";
          description = "Type of SSH public key";
        };
        key = mkOption {
          type = types.str;
          description = "Public key of SSH key";
        };
        _algorithm = mkOption {
          type = types.str;
          description = "Algorithm of the key";
          internal = true;
          visible = false;
        };
      };
      config = mkMerge [
        { _algorithm = keyAlgorithm config.key; }
      ];
    };
  userOpts =
    { name, config, ... }:
    {
      options = {
        name = mkOption {
          type = types.passwdEntry types.str;
          apply =
            x:
            assert (
              stringLength x < 32 || abort "Username '${x}' is longer than 31 characters which is not allowed!"
            );
            x;
          description = ''
            The name of the user's account. If undefined, the name of the
            attribute set will be used.
          '';
        };
        fullName = mkOption {
          type = types.passwdEntry types.str;
          default = "";
          description = "User's full name";
        };
        email = mkOption {
          type = types.passwdEntry types.str;
          default = "";
          description = "User's email address";
        };
        isAdmin = mkOption {
          type = types.bool;
          default = false;
          description = "User is an admin";
        };
        sshKey = mkOption {
          type = types.nullOr (
            types.coercedTo types.str (s: {
              type = "ssh";
              key = s;
            }) (types.submodule sshKeyOpts)
          );
          default = null;
          description = "SSH public key";
        };
        gpgKey = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = "GPG public key";
        };
        initialHashedPassword = mkOption {
          type = types.nullOr (types.passwdEntry types.str);
          default = null;
          description = ''
            Initial hashed password created with mkpasswd.
            The order of precedence is as shown below, where values on the left are overridden by values on the right:
            {option}`name` -> {option}`initialHashedPassword` -> {option}`hashedPasswordFile`
          '';
        };
        hashedPasswordFile = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = ''
            Hashed password file created with mkpasswd.
            The order of precedence is as shown below, where values on the left are overridden by values on the right:
            {option}`name` -> {option}`initialHashedPassword` -> {option}`hashedPasswordFile`
          '';
        };
      };
      config = mkMerge [
        {
          name = mkDefault name;
        }
      ];
    };
in
{
  options = {
    nix-configs.users = mkOption {
      type = types.attrsOf (types.submodule userOpts);
      description = "List of user definitions";
      default = { };
    };
  };
}

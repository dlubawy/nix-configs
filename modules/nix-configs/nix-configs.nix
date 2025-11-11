{ lib, ... }:
let
  inherit (lib)
    mkDefault
    mkMerge
    mkOption
    stringLength
    types
    ;
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
        sshKey = mkOption {
          type = types.nullOr types.str;
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
          description = "Initial hashed password created with mkpasswd";
        };
        hashedPasswordFile = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = "Path to hashed password file setup with mkpasswd";
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

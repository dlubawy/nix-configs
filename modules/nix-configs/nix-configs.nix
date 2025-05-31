{ lib, ... }:
{
  options = {
    nix-configs.users = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            fullName = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              description = "User's full name";
            };
            email = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              description = "User's email address";
            };
            sshKey = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              description = "SSH publib key";
            };
            gpgKey = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              description = "GPG public key";
            };
          };
        }
      );
      description = "List of user definitions";
      default = { };
    };
  };
}

{ lib }:
{
  options = {
    name = lib.mkOption {
      type = "string";
      description = "Username";
      default = "drew";
    };
    fullName = lib.mkOption {
      type = "string";
      description = "User's full name";
      default = "Andrew Lubawy";
    };
    email = lib.mkOption {
      type = "string";
      description = "User's email address";
      default = "andrew@andrewlubawy.com";
    };
    sshKey = lib.mkOption {
      type = "string";
      description = "SSH publib key";
      default = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBz5R5RsCSXxzIduOV98T4yASCRbYrKVbzB7iZy9746P";
    };
    gpgKey = lib.mkOption {
      type = "string";
      description = "GPG public key";
      default = "6EEC861B7641B37D";
    };
    # homeDomain = {
    #   type = "string";
    #   description = "Domain name owned by the user";
    #   default = "home.andrewlubawy.com";
    # };
    # stateVersion = "24.05";
  };

  config = {

  };
}

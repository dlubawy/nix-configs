{
  pkgs,
  lib,
  modulesPath,
  ...
}:
{
  imports = [
    ./disko.nix
    ./hardware.nix
    ./kde.nix
    ./topology.nix
    ../../users/drew.nix
  ];

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };

  networking = {
    hostName = "kepler";
  };

  virtualisation = {
    vmVariantWithDisko = {
      virtualisation = {
        host.pkgs = import pkgs.path { system = "aarch64-darwin"; };
      };
    };
    vmVariant = {
      virtualisation = {
        host.pkgs = import pkgs.path { system = "aarch64-darwin"; };
        memorySize = 4096;
        cores = 2;
      };
    };
  };
}

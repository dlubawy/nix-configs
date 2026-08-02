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

  build-vm = {
    enable = true;
    system = "aarch64-darwin";
  };
}

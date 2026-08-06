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

  services = {
    printing = {
      enable = true;
      cups-pdf.enable = true;
    };
    avahi.enable = true;
  };

  networking = {
    hostName = "kepler";
  };

  build-vm = {
    enable = true;
    system = "aarch64-darwin";
  };
}

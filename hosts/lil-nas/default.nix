{
  config,
  lib,
  outputs,
  ...
}:
{
  imports = [
    ./disko.nix
    ./hardware-configuration.nix
    ../../users/default.nix
  ];

  gui.enable = false;
}

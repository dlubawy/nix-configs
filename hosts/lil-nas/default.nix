{
  ...
}:
{
  imports = [
    ./disko.nix
    ./hardware.nix
    ./topology.nix
    ../../users/default.nix
  ];

  networking.hostName = "lil-nas";
  home-manager.gui.enable = false;
  users.shadow.enable = true;
}

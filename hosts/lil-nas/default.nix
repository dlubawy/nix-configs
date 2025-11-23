{
  ...
}:
{
  imports = [
    ./disko.nix
    ./hardware.nix
    ../../users/default.nix
  ];

  home-manager.gui.enable = false;
  users.shadow.enable = true;
}

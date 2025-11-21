{
  ...
}:
{
  imports = [
    ./disko.nix
    ./hardware-configuration.nix
    ../../users/default.nix
  ];

  home-manager.gui.enable = false;
  users.shadow.enable = true;
}

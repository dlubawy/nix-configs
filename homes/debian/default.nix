{ ... }:
{
  imports = [
    ../../users/drew.nix
  ];

  nix-configs.users.drew.name = "droid";
  gui.enable = false;
  programs = {
    nixvim.plugins.image.enable = false;
    tmux.shortcut = "b";
  };
}

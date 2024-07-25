# TODO: need to migrate old configs over
{ lib, ... }:
{
  wayland.windowManager.hyprland = {
    enable = lib.mkDefault false;
  };
}

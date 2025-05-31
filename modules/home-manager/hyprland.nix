# TODO: need to migrate old configs over
{ lib, config, ... }:
let
  cfg = config.gui.programs.hyprland;
in
{
  options = {
    gui.programs.hyprland.enable = lib.mkEnableOption "Enable Hyprland";
  };

  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      enable = true;
    };
  };
}

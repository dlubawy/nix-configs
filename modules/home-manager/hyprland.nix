# TODO: need to migrate old configs over
{
  lib,
  config,
  modulesPath,
  ...
}:
let
  cfg = config.gui.programs.hyprland;
in
{
  imports = [
    "${modulesPath}/services/window-managers/hyprland.nix"
  ];

  options = {
    gui.programs.hyprland.enable = lib.mkEnableOption "Enable Hyprland";
  };

  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      systemd.enable = false;
      enable = true;
    };
  };
}

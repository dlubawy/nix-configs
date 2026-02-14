{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib) mkForce concatMapAttrs mkIf;
  cfg = config.programs.hyprland;
  nixConfigUsers = config.nix-configs.users;
in
{
  config = mkIf cfg.enable {
    programs = {
      hyprland = {
        withUWSM = true;
        xwayland.enable = true;
      };
      hyprlock = {
        enable = cfg.enable;
      };
    };
    services = {
      hypridle = {
        enable = cfg.enable;
      };
    };
    xdg.portal = {
      enable = mkForce true;
      extraPortals = with pkgs; [ xdg-desktop-portal-hyprland ];
      config = {
        common = {
          default = [
            "hyprland"
          ];
        };
      };
    };

    home-manager.users = (
      concatMapAttrs (name: value: {
        ${name} = {
          gui.programs.hyprland.enable = mkForce cfg.enable;
        };
      }) nixConfigUsers
    );
  };
}

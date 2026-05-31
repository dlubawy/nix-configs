{
  pkgs,
  lib,
  ...
}:
let
  inherit (lib) strings;
in
{
  config = {
    systemd = {
      network.wait-online.enable = false;
    };
    environment = {
      plasma6.excludePackages = (builtins.attrValues { inherit (pkgs.kdePackages) konsole; });
      systemPackages = (
        builtins.attrValues {
          inherit (pkgs)
            catppuccin-gtk
            catppuccin-kde
            krita
            maliit-keyboard
            nextcloud-client
            papirus-icon-theme
            vlc
            xournalpp
            ;
          inherit (pkgs.catppuccin-cursors) frappeLavender;
          inherit (pkgs.nixos-artwork.wallpapers) catppuccin-frappe;
          inherit (pkgs.kdePackages)
            calligra
            kamoso
            kcalc
            kdenlive
            ;
        }
      );
    };
    services = {
      desktopManager.plasma6.enable = true;
      displayManager.sddm = {
        enable = true;
        wayland = {
          enable = true;
          compositor = "kwin";
        };
        settings = {
          Wayland = {
            CompositorCommand = strings.concatStringsSep " " [
              "${lib.getBin pkgs.kdePackages.kwin}/bin/kwin_wayland"
              "--no-global-shortcuts"
              "--no-kactivities"
              "--no-lockscreen"
              "--locale1"
              "--inputmethod maliit-keyboard"
            ];
          };
        };
      };
      flatpak.enable = true;
    };
  };
}

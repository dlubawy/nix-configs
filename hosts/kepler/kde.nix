{
  pkgs,
  ...
}:
{
  config = {
    # Fonts file needs overwrite and cannot set specifically
    home-manager.overwriteBackup = true;
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
            plasma-keyboard
            ;
        }
      );
    };
    services = {
      desktopManager.plasma6.enable = true;
      displayManager.plasma-login-manager.enable = true;
      flatpak.enable = true;
    };
  };
}

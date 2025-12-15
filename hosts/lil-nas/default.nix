{
  lib,
  ...
}:
let
  inherit (lib) mkForce;
in
{
  imports = [
    ../../users/default.nix
    ./disko.nix
    ./hardware.nix
    ./jellyfin.nix
    ./topology.nix
  ];

  networking = {
    hostName = "lil-nas";
    networkmanager.enable = mkForce false;
  };

  home-manager.gui.enable = false;
  users.shadow.enable = true;

  preservation.enable = true;

  time.timeZone = "America/Los_Angeles";
  i18n.defaultLocale = "en_US.UTF-8";

  services = {
    avahi = {
      enable = true;
      publish = {
        enable = true;
        addresses = true;
        domain = true;
      };
    };

    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
      };
    };

    tailscale = {
      enable = false;
      # authKeyFile = config.age.secrets.tailscale.path;
      extraUpFlags = [
        "--advertise-tags=tag:server"
      ];
    };

    zfs = {
      autoScrub = {
        enable = true;
        interval = "weekly";
      };
      autoSnapshot.enable = true;
    };
  };
}

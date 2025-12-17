{
  config,
  lib,
  inputs,
  ...
}:
let
  inherit (lib) mkForce mkIf;
in
{
  imports = [
    ../../users/default.nix
    ./disko.nix
    ./grafana
    ./hardware.nix
    ./jellyfin.nix
    ./topology.nix
    inputs.agenix.nixosModules.default
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

  age = {
    identityPaths = [ "/persist/.rw-etc/upper/ssh/ssh_host_ed25519_key" ];
    secrets = {
      tailscale = {
        file = ../../secrets/tailscale.age;
      };
    };
  };

  systemd.services.tailscaled.after = mkIf (config.systemd.network.wait-online.enable) [
    "systemd-networkd-wait-online.service"
  ];
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
      enable = true;
      authKeyFile = config.age.secrets.tailscale.path;
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

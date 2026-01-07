{
  lib,
  inputs,
  ...
}:
let
  inherit (lib) mkForce;
in
{
  imports = [
    ../../users/default.nix
    ./disko.nix
    ./grafana
    ./hardware.nix
    ./jellyfin.nix
    ./loki.nix
    ./nextcloud.nix
    ./prometheus.nix
    ./tailscale.nix
    ./topology.nix
    inputs.agenix.nixosModules.default
  ];

  options = {
    cloudDomain = lib.mkOption {
      type = lib.types.str;
      description = "Domain name for the Nextcloud ACME cert";
      default = "cloud.andrewlubawy.com";
    };
    collaboraDomain = lib.mkOption {
      type = lib.types.str;
      description = "Domain name for the Collabora ACME cert";
      default = "collabora.andrewlubawy.com";
    };
  };

  config = {
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
    };

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

      zfs = {
        autoScrub = {
          enable = true;
          interval = "weekly";
        };
        autoSnapshot.enable = true;
      };
    };
  };
}

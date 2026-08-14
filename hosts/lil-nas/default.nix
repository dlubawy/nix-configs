{
  pkgs,
  lib,
  inputs,
  outputs,
  vars,
  ...
}:
let
  inherit (lib) mkForce;
  topology = outputs.topology.${pkgs.stdenv.hostPlatform.system}.config;
  inherit (topology.lib.helpers) getAddress;
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
    ./nginx.nix
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

    security.auditd.enable = true;

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

    systemd = {
      timers = {
        nixos-upgrade-pi = {
          wantedBy = [ "timers.target" ];
          timerConfig = {
            OnBootSec = "20m";
            OnCalendar = "weekly";
            Unit = "nixos-update-pi.service";
          };
        };
      };
      services = {
        nixos-upgrade-pi =
          let
            piAddress = getAddress "pi" "enu1u1";
          in
          {
            path = (builtins.attrValues { inherit (pkgs) nixos-rebuild-ng openssh; });
            script = "nixos-rebuild switch --target-host root@${piAddress} --build-host root@${piAddress} --use-substitutes --flake ${vars.flake}#pi";
            environment = {
              NIX_SSHOPTS = "-p 2222 -i /etc/ssh/ssh_host_ed25519_key";
            };
            serviceConfig = {
              NoNewPrivileges = true;
              ProtectKernelLogs = true;
              ProtectKernelModules = true;
              ProtectKernelTunables = true;
            };
          };
      };
    };
  };
}

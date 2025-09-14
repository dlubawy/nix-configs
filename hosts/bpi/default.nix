{
  lib,
  config,
  inputs,
  vars,
  ...
}:
let
  homeDomain = config.homeDomain;
in
{
  imports = [
    inputs.agenix.nixosModules.default
    inputs.nixos-sbc.nixosModules.boards.bananapi.bpir3
    inputs.nixos-sbc.nixosModules.default
    ./adguardhome.nix
    ./grafana
    ./hardware.nix
    ./hostapd.nix
    ./kernel
    ./loki.nix
    ./network.nix
    ./nginx.nix
    ./prometheus.nix
    ./topology.nix
    ../../users/drew.nix
  ];

  options = {
    homeDomain = lib.mkOption {
      type = lib.types.str;
      description = "Domain name for the ACME cert";
      default = "home.andrewlubawy.com";
    };
  };

  config = {
    # Disable incompatible configs
    networking.networkmanager.enable = lib.mkForce false;
    boot.initrd.systemd.enable = lib.mkForce false;
    system.etc.overlay.enable = lib.mkForce false;
    systemd.sysusers.enable = lib.mkForce false;

    # FIXME: ISSUE[#91] remove when systemd v257.9 is backported
    system = {
      autoUpgrade = {
        enable = lib.mkForce false;
        allowReboot = lib.mkForce false;
      };
    };

    # FIXME: System seems unstable after 24h uptime so let's reboot everyday
    systemd.timers = {
      "scheduled-reboot" = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "Mon..Fri,Sun *-*-* 04:00:00";
          Unit = "reboot.target";
        };
      };
    };

    nix = {
      settings = {
        cores = 2;
        max-jobs = 2;
      };
    };

    sbc = {
      wireless.wifi.acceptRegulatoryResponsibility = true;
      version = "0.3";
    };

    swapDevices = [
      {
        device = "/var/lib/swapfile";
        size = 4096;
      }
    ];

    system.autoUpgrade = {
      dates = "Sat *-*-* 00:00:00";
      flake = "${vars.flake}#bpi";
    };

    home-manager.users = (
      lib.concatMapAttrs (name: _: {
        ${name} = {
          gui.enable = false;

          systemd.user.services.taildrive = lib.mkIf config.services.tailscale.enable {
            Unit = {
              Description = "Tailscale drive service";
              After = [ "tailscale.service" ];
            };
            Service = {
              Type = "oneshot";
              RemainAfterExit = true;
              ExecStart = "${config.services.tailscale.package}/bin/tailscale drive %h/Documents/org";
            };
          };
        };
      }) config.nix-configs.users
    );

    networking = {
      hostName = "bpi";
    };

    time.timeZone = "America/Los_Angeles";

    i18n.defaultLocale = "en_US.UTF-8";

    age = {
      secrets = {
        tailscale = {
          file = ../../secrets/tailscale.age;
        };
        cloudflare-dns-token = {
          file = ../../secrets/cloudflare-dns-token.age;
        };
      };
    };

    security = {
      acme = {
        acceptTerms = true;
        defaults = {
          email = "${vars.admin.email}";
          dnsResolver = "1.1.1.1:53";
        };
        certs = {
          "${homeDomain}" = {
            dnsProvider = "cloudflare";
            credentialFiles = {
              CLOUDFLARE_DNS_API_TOKEN_FILE = config.age.secrets.cloudflare-dns-token.path;
            };
          };
        };
      };
    };

    services = {
      openssh = {
        enable = true;
        listenAddresses = [
          {
            addr = "192.168.1.1";
            port = 22;
          }
        ];
        settings = {
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;
        };
        openFirewall = false;
      };

      tailscale = {
        enable = true;
        authKeyFile = config.age.secrets.tailscale.path;
        disableTaildrop = true;
        useRoutingFeatures = "server";
        extraUpFlags = [
          "--advertise-tags=tag:router"
          "--advertise-routes=192.168.1.1/32,192.168.30.0/24"
          "--advertise-exit-node"
          "--accept-dns=false"
        ];
      };
    };
  };
}

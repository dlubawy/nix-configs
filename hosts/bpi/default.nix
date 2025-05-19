{
  lib,
  config,
  inputs,
  outputs,
  vars,
  ...
}:
{
  imports = [
    inputs.agenix.nixosModules.default
    inputs.nixos-sbc.nixosModules.boards.bananapi.bpir3
    inputs.nixos-sbc.nixosModules.default
    ../../nixos
    ./adguardhome.nix
    ./grafana
    ./hostapd.nix
    ./kernel
    ./loki.nix
    ./network.nix
    ./nginx.nix
    ./prometheus.nix
    ./topology.nix
  ];

  # Disable incompatible configs
  networking.networkmanager.enable = lib.mkForce false;
  boot.initrd.systemd.enable = lib.mkForce false;
  system.etc.overlay.enable = lib.mkForce false;
  systemd.sysusers.enable = lib.mkForce false;

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
    buildMachines = [
      {
        hostName = "nix-builder";
        systems = [
          "x86_64-linux"
          "aarch64-linux"
        ];
        protocol = "ssh-ng";
        maxJobs = 1;
        speedFactor = 2;
        supportedFeatures = [
          "nixos-test"
          "benchmark"
          "big-parallel"
          "kvm"
        ];
        mandatoryFeatures = [ ];
      }
    ];
    distributedBuilds = true;
    settings = {
      cores = 2;
      max-jobs = 2;
      builders-use-substitutes = true;
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

  environment.shellAliases = {
    bpi = "sudo nixos-rebuild switch --flake github:dlubawy/nix-configs/main#bpi";
  };

  home-manager = {
    extraSpecialArgs = {
      inherit inputs outputs vars;
    };
    users.${vars.user}.gui.enable = false;
  };

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
        email = "${vars.email}";
        dnsResolver = "1.1.1.1:53";
      };
      certs = {
        "${vars.homeDomain}" = {
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
}

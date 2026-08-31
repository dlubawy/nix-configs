{
  pkgs,
  lib,
  inputs,
  modulesPath,
  ...
}:
let
  inherit (lib) mkOption types mkForce;
in
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/installer/sd-card/sd-image-aarch64.nix")
    inputs.nixos-hardware.nixosModules.raspberry-pi-3
    inputs.agenix.nixosModules.default
    ../../users/drew.nix
    ./alloy.nix
    ./home-assistant.nix
    ./prometheus.nix
    ./topology.nix
  ];

  options = {
    homeAssistantDomain = mkOption {
      type = types.str;
      description = "Domain name for Home Assistant";
      default = "assistant.andrewlubawy.com";
    };
  };

  config = {
    system.autoUpgrade.dates = mkForce "Sat *-*-* 02:00:00";
    nix.gc.dates = mkForce "Sun *-*-* 02:00:00";
    # Conflict services in order to clear up memory for maintenance operations
    systemd = {
      services = {
        nixos-upgrade = {
          conflicts = [
            "podman-homeassistant.service"
            "nix-gc.service"
          ];
          onSuccess = [ "podman-homeassistant.service" ];
          onFailure = [ "podman-homeassistant.service" ];
        };
        nix-gc = {
          conflicts = [
            "podman-homeassistant.service"
            "nixos-upgrade.service"
          ];
          onSuccess = [ "podman-homeassistant.service" ];
          onFailure = [ "podman-homeassistant.service" ];
        };
        # Need bluetooth service to restart when home-assistant does
        bluetooth = {
          before = [ "podman-homeassistant.service" ];
          partOf = [ "podman-homeassistant.service" ];
          wantedBy = [ "podman-homeassistant.service" ];
        };
      };
    };
    security.auditd.enable = true;
    swapDevices = [
      {
        device = "/var/lib/swapfile";
        size = 2048;
      }
    ];
    boot.supportedFilesystems.zfs = lib.mkForce false;
    hardware = {
      bluetooth.enable = true;
    };
    networking = {
      hostName = "pi";
      networkmanager.enable = lib.mkForce false;
      useDHCP = lib.mkForce false;
      interfaces.enu1u1.useDHCP = true;
    };

    home-manager.minimal = true;

    time.timeZone = "America/Los_Angeles";
    i18n.defaultLocale = "en_US.UTF-8";

    services = {
      tailscale = {
        enable = true;
        bootstrap = {
          enable = true;
          tags = [ "server" ];
        };
        ssh.enable = true;
      };

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
    };

    build-vm = {
      enable = true;
      system = "aarch64-darwin";
      memorySize = 1024;
    };
  };
}

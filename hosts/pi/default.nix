{
  pkgs,
  lib,
  inputs,
  modulesPath,
  ...
}:
let
  inherit (lib) mkOption types;
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
    # NOTE: the Pi does not have enough memory to upgrade automatically
    # TODO: Setup a push automation to update the Pi ISSUE(#293)
    system.autoUpgrade.enable = lib.mkForce false;
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
      networkmanager.enable = false;
    };

    home-manager.gui.enable = false;

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

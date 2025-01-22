{
  lib,
  inputs,
  outputs,
  vars,
  ...
}:
{
  imports = [
    inputs.agenix.nixosModules.default
    inputs.nixos-sbc.nixosModules.default
    inputs.nixos-sbc.nixosModules.boards.bananapi.bpir3
    ../../nixos
    ./network.nix
    ./adguardhome.nix
    ./hostapd.nix
    ./prometheus.nix
    ./grafana
  ];

  # Disable incompatible configs
  networking.networkmanager.enable = lib.mkForce false;
  boot.initrd.systemd.enable = lib.mkForce false;
  system.etc.overlay.enable = lib.mkForce false;
  systemd.sysusers.enable = lib.mkForce false;

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

  system.autoUpgrade.flake = "${vars.flake}#bpi";

  environment.shellAliases = {
    bpi = "sudo nixos-rebuild switch --flake github:dlubawy/nix-configs/main#bpi";
  };

  home-manager = {
    extraSpecialArgs = {
      inherit inputs outputs vars;
      enableGUI = false;
    };
  };

  networking = {
    hostName = "bpi";
  };

  time.timeZone = "America/Los_Angeles";

  i18n.defaultLocale = "en_US.UTF-8";

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
  };
}

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

  # mkBefore is very important here, otherwise it won't be used over linux-firmware files.
  # hardware.firmware = lib.mkBefore [
  #   (pkgs.stdenvNoCC.mkDerivation {
  #     name = "openwrt-mtk-firmware";
  #     src = pkgs.fetchFromGitHub {
  #       owner = "openwrt";
  #       repo = "mt76";
  #       rev = "master";
  #       sha256 = "";
  #     };
  #     dontPatch = true;
  #     dontConfigure = true;
  #     dontBuild = true;
  #     dontFixup = true;
  #     installPhase = ''
  #       mkdir -p $out/lib/firmware/mediatek
  #       mv firmware/* $out/lib/firmware/mediatek/
  #     '';
  #   })
  # ];

  sbc = {
    wireless.wifi.acceptRegulatoryResponsibility = true;
    version = "0.2";
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

{
  inputs,
  outputs,
  vars,
  ...
}:
{
  imports = [
    inputs.agenix.nixosModules.default
    ./hardware-configuration.nix
    ./adguardhome.nix
  ];

  system.autoUpgrade.flake = "${vars.flake}#pi";

  environment.shellAliases = {
    pi = "sudo nixos-rebuild switch --flake github:dlubawy/nix-configs/main#pi";
  };

  home-manager.users.${vars.user}.gui.enable = false;

  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  networking = {
    hostName = "pi";
    firewall = {
      allowedTCPPorts = [
        53
        80
      ];
      allowedUDPPorts = [ 53 ];
    };
  };

  time.timeZone = "America/Los_Angeles";

  i18n.defaultLocale = "en_US.UTF-8";

  services = {
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
      };
    };
  };
}

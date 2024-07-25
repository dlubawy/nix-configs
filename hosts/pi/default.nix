{
  config,
  pkgs,
  inputs,
  outputs,
  vars,
  ...
}:
{
  imports = [
    inputs.agenix.nixosModules.default
    ../../nixos
    ./hardware-configuration.nix
  ];

  home-manager = {
    extraSpecialArgs = {
      inherit inputs outputs vars;
      enableGUI = false;
    };
  };

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
    adguardhome = {
      enable = true;
      host = "127.0.0.1";
      port = 3000;
      settings = {
        users = [
          {
            name = "admin";
            password = "@adguardhome-password@";
          }
        ];
      };
    };
    nginx = {
      enable = true;
      virtualHosts = {
        "adguard.home" = {
          locations."/" = {
            proxyPass = "http://localhost:3000";
          };
        };
      };
    };
  };

  age = {
    secrets = {
      adguardhome = {
        file = ../../secrets/adguardhome.age;
      };
    };
  };

  system.activationScripts."adguardhome-secret" = ''
    secret=$(cat "${config.age.secrets.adguardhome.path}")
    configFile=/var/lib/AdGuardHome/AdGuardHome.yaml
    ${pkgs.gnused}/bin/sed -i "s#@adguardhome-password@#$secret#" "$configFile"
  '';
}

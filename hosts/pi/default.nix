{
  lib,
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

  environment.shellAliases = {
    pi = "sudo nixos-rebuild switch --flake github:dlubawy/nix-configs/main#pi";
  };

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
        mode = "0444";
      };
    };
  };

  systemd.services.adguardhome.preStart =
    let
      cfg = config.services.adguardhome;
      settingsFormat = pkgs.formats.yaml { };
      settings =
        if (cfg.settings != null) then
          cfg.settings
          // (
            if cfg.settings.schema_version < 23 then
              {
                bind_host = cfg.host;
                bind_port = cfg.port;
              }
            else
              { http.address = "${cfg.host}:${toString cfg.port}"; }
          )
        else
          null;
      configFile = (settingsFormat.generate "AdGuardHome.yaml" settings).overrideAttrs (_: {
        checkPhase = "${cfg.package}/bin/adguardhome -c $out --check-config";
      });
    in
    lib.mkForce (
      lib.optionalString (settings != null) ''
        if    [ -e "$STATE_DIRECTORY/AdGuardHome.yaml" ] \
           && [ "${toString cfg.mutableSettings}" = "1" ]; then
          # Writing directly to AdGuardHome.yaml results in empty file
          ${pkgs.yaml-merge}/bin/yaml-merge "$STATE_DIRECTORY/AdGuardHome.yaml" "${configFile}" "${config.age.secrets.adguardhome.path}" > "$STATE_DIRECTORY/AdGuardHome.yaml.tmp"
          mv "$STATE_DIRECTORY/AdGuardHome.yaml.tmp" "$STATE_DIRECTORY/AdGuardHome.yaml"
        else
          cp --force "${configFile}" "$STATE_DIRECTORY/AdGuardHome.yaml"
          chmod 600 "$STATE_DIRECTORY/AdGuardHome.yaml"
        fi
      ''
    );
}

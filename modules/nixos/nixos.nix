{
  pkgs,
  lib,
  config,
  inputs,
  vars,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkDefault
    mkIf
    mkMerge
    ;
  systemName = config.networking.hostName;
in
{
  imports = [
    inputs.nix-topology.nixosModules.default
    inputs.nixvim.nixosModules.nixvim
    inputs.lanzaboote.nixosModules.lanzaboote
    ./nix.nix
    ./users.nix
    ./preservation.nix
  ];

  options = {
    topology.enable = mkEnableOption "Enable system in topology view";
    boot.secure.enable = mkEnableOption ''
      Enables secure boot using lanzaboote (enable after `sudo sbctl create-keys`)
      Additional docs: https://github.com/nix-community/lanzaboote/blob/master/docs/QUICK_START.md
    '';
  };

  config = {
    assertions = [
      {
        assertion =
          (config.boot.secure.enable)
          -> (config.boot.lanzaboote.enable && (!config.boot.loader.systemd-boot.enable));
        message = "When secure boot is enabled lanzaboote is enabled and systemd-boot is disabled";
      }
    ];

    environment = {
      systemPackages = with pkgs; [ sbctl ];
      shellAliases = {
        "${systemName}" = "sudo nixos-rebuild switch --flake ${vars.flake}#${systemName}";
      };
    };

    boot = mkMerge [
      {
        initrd.systemd.enable = mkDefault true;
      }
      (mkIf config.boot.secure.enable {
        loader.systemd-boot.enable = mkDefault false;
        lanzaboote = {
          enable = mkDefault true;
          pkiBundle = "/var/lib/sbctl";
        };
      })
    ];

    programs = {
      nixvim = {
        enable = true;
      };

      zsh = {
        enable = true;
        enableCompletion = true;
        enableBashCompletion = true;
        autosuggestions.enable = true;
        syntaxHighlighting.enable = true;
      };

      starship.enable = true;
    };

    networking = {
      networkmanager.enable = true;
    };

    system = {
      autoUpgrade = {
        enable = lib.mkDefault true;
        dates = lib.mkDefault "weekly";
        allowReboot = lib.mkDefault true;
        rebootWindow = lib.mkDefault {
          lower = "01:00";
          upper = "05:00";
        };
      };
      etc.overlay.enable = true;
      stateVersion = "${vars.stateVersion}";
    };
  };
}

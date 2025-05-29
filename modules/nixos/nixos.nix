{
  lib,
  pkgs,
  config,
  inputs,
  outputs,
  vars,
  ...
}:
let
  systemName = config.networking.hostName;
in
{
  imports = [
    inputs.nix-topology.nixosModules.default
    inputs.nixvim.nixosModules.nixvim
    ./users.nix
  ];

  config = {
    nixpkgs = {
      overlays = builtins.attrValues outputs.overlays;
    };

    environment.shellAliases = {
      bpi = "sudo nixos-rebuild switch --flake ${vars.flake}#${systemName}";
    };

    boot.initrd.systemd.enable = true;

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

    services.userborn.enable = true;
    xdg.portal = {
      configPackages = with pkgs; [ xdg-desktop-portal-hyprland ];
      wlr.enable = true;
    };

    nix = {
      enable = true;
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
      };
      optimise.automatic = true;
      settings = {
        experimental-features = "nix-command flakes";
        substituters = vars.nixConfig.extra-substituters;
        trusted-public-keys = vars.nixConfig.extra-trusted-public-keys;
      };
    };
  };
}

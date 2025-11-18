{
  lib,
  config,
  inputs,
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
    ./nix.nix
    ./users.nix
  ];

  config = {
    environment.shellAliases = {
      "${systemName}" = "sudo nixos-rebuild switch --flake ${vars.flake}#${systemName}";
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
  };
}

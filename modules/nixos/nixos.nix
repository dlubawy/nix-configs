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
    mkOption
    types
    ;
  systemName = config.networking.hostName;
in
{
  imports = [
    ./agenix.nix
    ./disko.nix
    ./hyprland.nix
    ./nix.nix
    ./preservation.nix
    ./tailscale.nix
    ./users.nix
    inputs.lanzaboote.nixosModules.lanzaboote
    inputs.nix-topology.nixosModules.default
    inputs.nixvim.nixosModules.nixvim
  ];

  options = {
    topology.enable = mkEnableOption "Enable system in topology view";
    boot.secure.enable = mkEnableOption ''
      Enables secure boot using lanzaboote (enable after `sudo sbctl create-keys`)
      Additional docs: https://github.com/nix-community/lanzaboote/blob/master/docs/QUICK_START.md
    '';
    build-vm = {
      enable = mkEnableOption "Enable build-vm configuration";
      system = mkOption {
        type = types.str;
        description = "Host system for `nixos-rebuild build-vm`";
        default = pkgs.stdenv.buildPlatform.system;
      };
      cores = mkOption {
        type = types.int;
        description = "CPU core count for VM";
        default = 2;
      };
      memorySize = mkOption {
        type = types.int;
        description = "Memory in MiB for VM";
        default = 4096;
      };
    };
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
      systemPackages = builtins.attrValues { inherit (pkgs) sbctl; };
      shellAliases = mkIf (builtins.hasAttr "flake" vars) {
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
        nixpkgs.source = inputs.nixpkgs;
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
      nftables.enable = lib.mkDefault true;
      useNetworkd = lib.mkDefault true;
    };

    systemd.network.enable = lib.mkDefault true;

    system = {
      autoUpgrade = mkIf (builtins.hasAttr "flake" vars) {
        enable = lib.mkDefault true;
        flake = lib.mkDefault "${vars.flake}#${config.networking.hostName}";
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

    virtualisation = mkIf config.build-vm.enable {
      vmVariantWithDisko = mkIf config.disko.enable {
        virtualisation = {
          host.pkgs = import pkgs.path { system = config.build-vm.system; };
        };
      };

      vmVariant = {
        virtualisation = {
          host.pkgs = import pkgs.path { system = config.build-vm.system; };
          memorySize = config.build-vm.memorySize;
          cores = config.build-vm.cores;
        };
      };
    };
  };
}

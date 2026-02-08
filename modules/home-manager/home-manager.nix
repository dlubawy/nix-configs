{
  lib,
  pkgs,
  config,
  vars,
  outputs,
  ...
}@args:
let
  inherit (lib)
    mkDefault
    mkIf
    mkOption
    types
    optionals
    ;
  useGlobalPkgs = builtins.hasAttr "darwinConfig" args || builtins.hasAttr "nixosConfig" args;
in
{
  imports = [
    ./agenix.nix
    ./alacritty.nix
    ./bat.nix
    ./git.nix
    ./gpg.nix
    ./kitty.nix
    ./nixvim.nix
    ./scripts
    ./ssh.nix
    ./starship.nix
    ./tmux.nix
    ./user.nix
    ./zsh.nix
    ./hyprland.nix
    ./qtpass.nix
  ];

  options = {
    gui.enable = mkOption {
      default = true;
      type = types.bool;
      description = "Enable GUI applications";
    };
  };

  config = {
    gui.programs = mkIf config.gui.enable {
      kitty.enable = mkDefault true;
      hyprland.enable = (!pkgs.stdenv.isDarwin);
      qtpass.enable = true;
    };
    nix = {
      package = mkIf (!useGlobalPkgs) pkgs.nix;
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
      };
      settings = {
        experimental-features = "nix-command flakes";
        extra-substituters = mkIf (!useGlobalPkgs) vars.nixConfig.extra-substituters;
        extra-trusted-public-keys = mkIf (!useGlobalPkgs) vars.nixConfig.extra-trusted-public-keys;
      };
    };

    nixpkgs = mkIf (!useGlobalPkgs) {
      overlays = (builtins.attrValues outputs.overlays);
      config = {
        allowUnfree = true;
      };
    };

    home = {
      preferXdgDirectories = true;

      packages =
        with pkgs;
        [
          age-plugin-yubikey
          gawk
          gnused
          gnutar
          gopass
          p7zip
          python3
          rage
          tig
          unzip
          wget
          which
          xz
          zip
          zstd
        ]
        ++ (optionals (config.gui.enable) [
          slack
          spotify
          zoom-us
        ]);

      stateVersion = "${vars.stateVersion}";
    };

    programs = {
      home-manager.enable = true;
      btop.enable = true;
      firefox = mkIf config.gui.enable { enable = mkDefault true; };
      eza = {
        enable = true;
        icons = "auto";
      };
      fd.enable = true;
      fzf = {
        enable = true;
        colors = {
          "bg+" = "#414559";
          bg = "#303446";
          spinner = "#f2d5cf";
          hl = "#e78284";
          fg = "#c6d0f5";
          header = "#e78284";
          info = "#ca9ee6";
          pointer = "#f2d5cf";
          marker = "#f2d5cf";
          "fg+" = "#c6d0f5";
          prompt = "#ca9ee6";
          "hl+" = "#e78284";
        };
      };
      ripgrep.enable = true;
      zoxide.enable = true;

      direnv = {
        enable = true;
        enableZshIntegration = true;
        nix-direnv.enable = true;
      };
    };

    # Nicely reload system units when changing configs
    systemd.user.startServices = "sd-switch";

    xdg.enable = true;
  };
}

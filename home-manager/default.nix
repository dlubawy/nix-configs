{
  lib,
  pkgs,
  inputs,
  vars,
  ...
}:
{
  imports = [
    inputs.nixvim.homeManagerModules.nixvim
    ./starship.nix
    ./tmux.nix
    ./zsh.nix
  ];

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };

  home = {
    username = "${vars.user}";
    homeDirectory = "/${if pkgs.stdenv.isDarwin then "Users" else "home"}/${vars.user}";

    packages = with pkgs; [
      btop
      gawk
      gnupg
      gnused
      gnutar
      p7zip
      python3
      ripgrep
      spotify
      tig
      tree
      unzip
      wget
      which
      xz
      zip
      zoom-us
      zstd
    ];

    stateVersion = "23.11";
  };

  programs = {
    home-manager.enable = true;
    firefox.enable = if pkgs.stdenv.isDarwin then false else true;

    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    git = {
      enable = true;
      userEmail = "${vars.email}";
      userName = "${vars.name}";
      ignores = [
        # Direnv
        ".direnv"
        ".envrc"

        # OS
        ".DS_Store"
        "ehthumbs.db"
        "Icon?"
        "Thumbs.db"

        # Editor
        "*~"
        "*.swp"
        "*.swo"
      ];
    };

    kitty = {
      enable = true;
      environment = {
        NIL_PATH = "${pkgs.nil}/bin/nil";
      };
      theme = "Catppuccin-Frappe";
      settings = {
        confirm_os_window_close = 0;
        enable_audio_bell = false;
        font_family = "FantasqueSansM Nerd Font Mono";
        font_size = 14;
      };
    };

    nixvim = lib.mkMerge [
      (import ../nixvim)
      {
        enable = true;
        defaultEditor = true;
      }
    ];
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}

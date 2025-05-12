{
  lib,
  pkgs,
  config,
  vars,
  outputs,
  ...
}@args:
let
  useGlobalPkgs = builtins.hasAttr "darwinConfig" args || builtins.hasAttr "nixosConfig" args;
in
{
  imports = [
    ./agenix.nix
    ./alacritty.nix
    ./git.nix
    ./gpg.nix
    ./nixvim.nix
    ./scripts
    ./ssh.nix
    ./starship.nix
    ./tmux.nix
    ./zsh.nix
    ./hyprland.nix
    ./qtpass.nix
  ];

  options = {
    gui.enable = lib.mkOption {
      default = true;
      type = lib.types.bool;
      description = "Enable GUI applications";
    };
  };

  config = {
    gui.programs = lib.mkIf config.gui.enable {
      alacritty.enable = true;
      hyprland.enable = (!pkgs.stdenv.isDarwin);
      qtpass.enable = true;
    };
    nix = {
      package = lib.mkIf (!useGlobalPkgs) pkgs.nix;
      gc = {
        automatic = true;
        frequency = "weekly";
        options = "--delete-older-than 7d";
      };
      settings = {
        experimental-features = "nix-command flakes";
        substituters = lib.mkIf (!useGlobalPkgs) vars.nixConfig.extra-substituters;
        trusted-public-keys = lib.mkIf (!useGlobalPkgs) vars.nixConfig.extra-trusted-public-keys;
      };
    };

    nixpkgs = {
      overlays = lib.mkIf (!useGlobalPkgs) (builtins.attrValues outputs.overlays);
      config = {
        allowUnfree = true;
      };
    };

    home = {
      username = "${vars.user}";
      homeDirectory = "/${if pkgs.stdenv.isDarwin then "Users" else "home"}/${vars.user}";
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
        ++ (lib.optionals (config.gui.enable) [
          slack
          spotify
          zoom-us
        ]);

      stateVersion = "${vars.stateVersion}";
    };

    programs = {
      home-manager.enable = true;
      btop.enable = true;
      firefox = lib.mkIf config.gui.enable { enable = lib.mkDefault true; };
      bat = {
        enable = true;
        config = {
          theme = "catppuccin-frappe";
        };
        themes = {
          catppuccin-frappe = {
            src = pkgs.fetchFromGitHub {
              owner = "catppuccin";
              repo = "bat";
              rev = "82e7ca555f805b53d2b377390e4ab38c20282e83";
              hash = "sha256-/Ob9iCVyjJDBCXlss9KwFQTuxybmSSzYRBZxOT10PZg=";
            };
            file = "./themes/Catppuccin Frappe.tmTheme";
          };
        };
      };
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

      kitty = lib.mkIf config.gui.enable {
        enable = lib.mkDefault false;
        themeFile = "Catppuccin-Frappe";
        settings = {
          confirm_os_window_close = 0;
          enable_audio_bell = false;
          font_family = "FantasqueSansM Nerd Font Mono";
          font_size = 14;
        };
      };
    };

    # Nicely reload system units when changing configs
    systemd.user.startServices = "sd-switch";

    xdg.enable = true;
  };
}

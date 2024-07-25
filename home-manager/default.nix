{
  lib,
  pkgs,
  vars,
  outputs,
  nixosConfig,
  darwinConfig,
  enableGUI ? true,
  ...
}:
let
  useGlobalPkgs =
    (darwinConfig != null && darwinConfig.home-manager.useGlobalPkgs)
    || (nixosConfig != null && nixosConfig.home-manager.useGlobalPkgs);
in
{
  imports =
    [
      ./agenix.nix
      ./git.nix
      ./gpg.nix
      ./nixvim.nix
      ./ssh.nix
      ./starship.nix
      ./tmux.nix
      ./zsh.nix
    ]
    ++ (lib.optionals (enableGUI) [
      ./alacritty.nix
      ./hyprland.nix
      ./qtpass.nix
    ]);

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
        bat
        fd
        fzf
        gawk
        gnused
        gnutar
        gopass
        p7zip
        python3
        rage
        ripgrep
        tig
        tree
        unzip
        wget
        which
        xz
        zip
        zoxide
        zstd
      ]
      ++ (lib.optionals (enableGUI) [
        spotify
        zoom-us
      ]);

    stateVersion = "${vars.stateVersion}";
  };

  programs = {
    home-manager.enable = true;
    btop.enable = true;
    firefox = lib.mkIf enableGUI { enable = lib.mkDefault true; };
    ripgrep.enable = true;

    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    kitty = lib.mkIf enableGUI {
      enable = lib.mkDefault true;
      theme = "Catppuccin-Frappe";
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
}

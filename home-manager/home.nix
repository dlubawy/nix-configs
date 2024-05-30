{
  pkgs,
  inputs,
  vars,
  ...
}:
{
  imports = [ inputs.nixvim.homeManagerModules.nixvim ];

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };

  home = {
    username = "${vars.user}";
    homeDirectory = "/${if pkgs.stdenv.isDarwin then "Users" else "home"}/${vars.user}";

    packages = with pkgs; [
      black
      fd
      fzf
      go
      imagemagick
      isort
      luajitPackages.magick
      nil
      nixfmt-rfc-style
      nodePackages_latest.eslint
      nodePackages_latest.prettier
      nodejs
      python3
      ripgrep
      rustup
      spotify
      sqlfluff
      stylua
      terraform
      terragrunt
      tig
      tree
      wget
      zoom-us
    ];

    stateVersion = "23.11";
  };

  programs = {
    home-manager.enable = true;
    firefox.enable = if pkgs.stdenv.isDarwin then false else true;
    git = {
      enable = true;
      userEmail = "${vars.email}";
      userName = "${vars.name}";
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

    nixvim = import ./programs/nixvim/nixvim.nix { inherit pkgs; };

    texlive = {
      enable = true;
      extraPackages = tpkgs: {
        inherit (tpkgs)
          scheme-small
          moderncv
          fontawesome5
          multirow
          arydshln
          ;
      };
    };

    starship = import ./programs/starship.nix;
    tmux = import ./programs/tmux.nix { inherit pkgs; };
    zsh = import ./programs/zsh.nix { inherit pkgs; };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}

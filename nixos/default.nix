{
  pkgs,
  inputs,
  outputs,
  vars,
  ...
}:
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    inputs.nixvim.nixosModules.nixvim
  ];

  nixpkgs = {
    overlays = builtins.attrValues outputs.overlays;
  };

  boot.initrd.systemd.enable = true;

  users = {
    users.${vars.user} = {
      isNormalUser = true;
      shell = pkgs.zsh;
      description = "${vars.name}";
      extraGroups = [
        "wheel"
        "networkmanager"
      ];
      initialPassword = "${vars.user}";
      openssh.authorizedKeys.keys = [ vars.sshKey ];
    };
  };

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
      enable = true;
      dates = "weekly";
      allowReboot = true;
      rebootWindow = {
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
    settings = {
      auto-optimise-store = true;
      experimental-features = "nix-command flakes";
    };
  };

  home-manager = {
    extraSpecialArgs = {
      inherit inputs outputs vars;
    };
    users.${vars.user} = import ../home-manager;
    useUserPackages = true;
    useGlobalPkgs = true;
  };
}

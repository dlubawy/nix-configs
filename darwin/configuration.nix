{
  pkgs,
  inputs,
  vars,
  ...
}:
{
  imports = [
    inputs.home-manager.darwinModules.home-manager
    inputs.nixvim.nixDarwinModules.nixvim
  ];

  nixpkgs = {
    system = "aarch64-darwin";
    overlays = [ ];
    config = {
      allowUnfree = true;
    };
  };

  networking = {
    computerName = "laplace";
    hostName = "laplace";
    knownNetworkServices = [
      "Wi-Fi"
      "USB 10/100/1000 LAN"
    ];
    dns = [
      "1.1.1.1"
      "1.0.0.1"
      "2606:4700:4700::1111"
      "2606:4700:4700::1001"
    ];
  };

  users.users.${vars.user} = {
    home = "/Users/${vars.user}";
    shell = pkgs.zsh;
  };

  environment = {
    shells = with pkgs; [ zsh ];
    shellAliases = {
      sudoedit = "sudo -e ";
    };
    variables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
    systemPackages = with pkgs; [ git ];
  };

  fonts = {
    fontDir.enable = true;
    fonts = with pkgs; [ (nerdfonts.override { fonts = [ "FantasqueSansMono" ]; }) ];
  };

  programs = {
    nixvim = {
      enable = true;
    };
    zsh = {
      enable = true;
      enableGlobalCompInit = false;
    };
  };

  services = {
    nix-daemon.enable = true;
  };

  nix = {
    package = pkgs.nix;
    gc = {
      automatic = true;
      interval.Day = 7;
      options = "--delete-older-than 7d";
    };
    settings.experimental-features = "nix-command flakes";
  };

  system = {
    defaults = {
      NSGlobalDomain = {
        "com.apple.swipescrolldirection" = false;
      };

      SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;

      alf = {
        globalstate = 1;
        stealthenabled = 1;
      };

      dock = {
        autohide = false;
        largesize = 72;
        tilesize = 48;
        magnification = true;
        mineffect = "genie";
        orientation = "bottom";
        showhidden = false;
        show-recents = false;
      };

      finder = {
        QuitMenuItem = false;
      };

      trackpad = {
        Clicking = true;
        TrackpadRightClick = true;
      };
    };
    stateVersion = 4;
  };

  security.pam.enableSudoTouchIdAuth = true;

  home-manager = {
    users.${vars.user} = import ../home-manager/home.nix { inherit pkgs inputs vars; };

    useGlobalPkgs = true;
    useUserPackages = true;
  };

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = false;
      upgrade = false;
      cleanup = "zap";
    };
    brews = [ "gnu-sed" ];
    casks = [ "firefox" ];
  };
}

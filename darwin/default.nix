{
  lib,
  pkgs,
  inputs,
  outputs,
  vars,
  ...
}:
let
  systemName = "laplace";
in
{
  imports = [
    inputs.home-manager.darwinModules.home-manager
    inputs.nixvim.nixDarwinModules.nixvim
  ];

  nixpkgs = {
    system = "aarch64-darwin";
    overlays = builtins.attrValues outputs.overlays;
    config = {
      allowUnfree = true;
    };
  };

  networking = {
    computerName = "${systemName}";
    hostName = "${systemName}";
    knownNetworkServices = [
      "Wi-Fi"
      "USB 10/100/1000 LAN"
    ];
    # Cloudflare
    dns = [
      "1.1.1.1"
      "1.0.0.1"
      "2606:4700:4700::1111"
      "2606:4700:4700::1001"
    ];
  };

  users = {
    # System admin
    users.${systemName} = {
      isNormalUser = true;
      isAdminUser = true;
      isTokenUser = true;
      isHidden = true;
      home = "/Users/${systemName}";
      initialPassword = "${systemName}";
    };
    # Regular user
    users.${vars.user} = {
      isNormalUser = true;
      isTokenUser = true;
      isHidden = false;
      shell = /bin/zsh;
      description = "${vars.name}";
      initialPassword = "${vars.user}";
    };
  };

  environment = {
    shells = with pkgs; [ zsh ];
    shellAliases = {
      sudoedit = "sudo -e ";
      ${systemName} = "sudo -Hu ${systemName} darwin-rebuild switch --flake github:dlubawy/nix-configs/main#${systemName}";
    };
    variables = {
      EDITOR = "nvim";
      VISUAL = "nvim";

      HOMEBREW_NO_INSECURE_REDIRECT = "1";
      HOMEBREW_NO_ANALYTICS = "1";
      ZSH_DISABLE_COMPFIX = "true";
    };
    systemPackages = with pkgs; [ git ];
  };

  fonts = {
    packages = with pkgs; [ (nerdfonts.override { fonts = [ "FantasqueSansMono" ]; }) ];
  };

  programs = {
    nixvim = {
      enable = true;
    };
    zsh = {
      enable = true;
      enableCompletion = true;
      enableBashCompletion = true;
      enableGlobalCompInit = false;
      enableSyntaxHighlighting = true;

      # Init brew
      loginShellInit = ''
        eval "$(/opt/homebrew/bin/brew shellenv)"
      '';
    };
  };

  services = {
    nix-daemon.enable = true;
  };

  nix = {
    gc = {
      automatic = true;
      interval.Day = 7;
      options = "--delete-older-than 7d";
      user = "${systemName}";
    };
    optimise.automatic = true;
    settings = {
      experimental-features = "nix-command flakes";
      trusted-users = [
        "root"
        "@admin"
      ];
    };
    # NOTE: disabled by default to save resources when not in use.
    # Change package attribute to switch between aarch64 and x86_64 architectures.
    # Need to build the default linux-builder first before using `config.virtualisation`.
    linux-builder = {
      enable = false;
      package = pkgs.darwin.linux-builder;
      # package = pkgs.darwin.linux-builder-x86_64;
      ephemeral = true;
      maxJobs = 2;
      systems = [
        "aarch64-linux"
        "x86_64-linux"
      ];
      config = {
        virtualisation = {
          darwin-builder = {
            diskSize = 30 * 1024;
            memorySize = 8 * 1024;
          };
        };
      };
    };
  };

  system = {
    defaults = {
      SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;

      alf = {
        globalstate = 1;
        stealthenabled = 1;
        loggingenabled = 1;
        allowdownloadsignedenabled = 0;
        allowsignedenabled = 0;
      };
      NSGlobalDomain = {
        "com.apple.swipescrolldirection" = false;
        NSDocumentSaveNewDocumentsToCloud = false;
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

      screensaver = {
        askForPassword = true;
        askForPasswordDelay = 0;
      };

      trackpad = {
        Clicking = true;
        TrackpadRightClick = true;
      };
    };
    stateVersion = 4;
  };

  security = {
    pam = {
      enableSudoTouchIdAuth = true;
      enablePamReattach = true;
    };
    # Allows standard user to run darwin-rebuild through the admin user
    # sudo -Hu ${systemName} darwin-rebuild
    sudo.extraConfig = ''
      ${vars.user} ALL = (${systemName}) ALL
    '';
  };

  home-manager = {
    extraSpecialArgs = {
      inherit inputs outputs vars;
      enableGUI = true;
    };
    users.${vars.user} = lib.mkMerge [
      (import ../home-manager)
      { programs.firefox.enable = false; }
    ];

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
    brews = [ ];
    casks = [ "firefox" ];
    caskArgs.require_sha = true;
  };
}

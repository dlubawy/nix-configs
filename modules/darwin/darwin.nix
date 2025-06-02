{
  lib,
  pkgs,
  config,
  inputs,
  outputs,
  vars,
  ...
}:
{
  imports = [
    inputs.nixvim.nixDarwinModules.nixvim
    ./users.nix
  ];

  options = {
    systemName = lib.mkOption {
      type = lib.types.str;
      description = "System name for deriving admin username and computer hostname";
    };
  };

  config =
    let
      systemName = config.systemName;
    in
    {
      nixpkgs = {
        system = "aarch64-darwin";
        overlays = (builtins.attrValues outputs.overlays) ++ [
          inputs.nixpkgs-firefox-darwin.overlay
        ];
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
      };

      environment = {
        shells = with pkgs; [ zsh ];
        shellAliases = {
          sudoedit = "sudo -Hu laplace sudo -e ";
          "${systemName}" =
            "sudo -Hu ${systemName} sudo darwin-rebuild switch --flake ${vars.flake}#${systemName}";
        };
        variables = {
          EDITOR = "nvim";
          VISUAL = "nvim";

          HOMEBREW_NO_INSECURE_REDIRECT = "1";
          HOMEBREW_NO_ANALYTICS = "1";
          ZSH_DISABLE_COMPFIX = "true";
        };
        systemPackages = with pkgs; [
          e2fsprogs
          fuse-ext2
          fuse-t
          git
          ntfs3g
        ];
      };

      fonts = {
        packages = with pkgs; [ nerd-fonts.fantasque-sans-mono ];
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
        tailscale = {
          enable = true;
          overrideLocalDns = true;
        };
      };

      nix = {
        enable = true;
        gc = {
          automatic = true;
          interval.Day = 7;
          options = "--delete-older-than 7d";
        };
        optimise.automatic = true;
        settings = {
          experimental-features = "nix-command flakes";
          substituters = vars.nixConfig.extra-substituters;
          trusted-public-keys = vars.nixConfig.extra-trusted-public-keys;
          trusted-users = [
            "root"
            "@admin"
          ];
        };

        # NOTE: Change package attribute to switch between aarch64 and x86_64 architectures.
        # Need to build the default linux-builder first before using `config.virtualisation`.
        linux-builder = {
          enable = true;
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
                diskSize = 50 * 1024;
                memorySize = 16 * 1024;
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
        };
        stateVersion = vars.darwinStateVersion;
      };

      security = {
        pam.services = {
          sudo_local = {
            enable = true;
            reattach = true;
            touchIdAuth = true;
          };
        };
      };

      homebrew = {
        enable = true;
        user = "laplace";
        onActivation = {
          autoUpdate = false;
          upgrade = false;
          cleanup = "zap";
        };
        brews = [ ];
        casks = [
          "ultimaker-cura"
        ];
        caskArgs.require_sha = true;
      };
    };
}

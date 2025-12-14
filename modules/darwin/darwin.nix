{
  lib,
  pkgs,
  config,
  inputs,
  outputs,
  vars,
  ...
}:
let
  inherit (lib)
    mkOption
    types
    ;
in
{
  imports = [
    inputs.nixvim.nixDarwinModules.nixvim
    ./users.nix
    ./topology.nix
  ];

  options = {
    systemName = mkOption {
      type = types.str;
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
        overlays = (builtins.attrValues outputs.overlays);
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
        applicationFirewall = {
          enable = true;
          blockAllIncoming = true;
          enableStealthMode = true;
          allowSignedApp = false;
          allowSigned = false;
        };
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
          nixos-rebuild = "${pkgs.nixos-rebuild-ng}/bin/nixos-rebuild-ng";
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
          nixos-rebuild-ng
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

        # NOTE: Need to build the default linux-builder first before using `config.virtualisation`.
        linux-builder = {
          enable = true;
          ephemeral = true;
          maxJobs = 2;
          systems = [
            "aarch64-linux"
            "x86_64-linux"
          ];
          config = {
            boot.binfmt.emulatedSystems = [ "x86_64-linux" ];
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

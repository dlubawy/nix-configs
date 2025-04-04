{
  description = "Andrew Lubawy's Nix Configs";

  inputs = {
    # Different nixpkgs sources
    nixpkgs.url = "github:NixOS/nixpkgs/release-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-24.11-darwin";

    # System modules
    darwin = {
      url = "github:dlubawy/nix-darwin/develop";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/2411.6.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-sbc = {
      url = "github:nakato/nixos-sbc/114b2e495a5a59b3d077e73a0a60c6945c5cf32e";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Supporting modules
    nixvim = {
      url = "github:nix-community/nixvim/nixos-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:dlubawy/agenix/armor_support";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pre-commit-hooks = {
      url = "github:cachix/git-hooks.nix/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Overlays
    nixpkgs-firefox-darwin = {
      url = "github:bandithedoge/nixpkgs-firefox-darwin";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      darwin,
      home-manager,
      nixos-wsl,
      nixvim,
      agenix,
      pre-commit-hooks,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      forAllSystems =
        f:
        nixpkgs.lib.genAttrs systems (
          system:
          f {
            pkgs = import nixpkgs {
              inherit system;
              config.allowUnfree = true;
            };
          }
        );

      # User config
      vars = {
        name = "Andrew Lubawy";
        email = "andrew@andrewlubawy.com";
        user = "drew";
        sshKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBz5R5RsCSXxzIduOV98T4yASCRbYrKVbzB7iZy9746P";
        gpgKey = "6EEC861B7641B37D";
        homeDomain = "home.andrewlubawy.com";
        stateVersion = "24.05";
        flake = "github:dlubawy/nix-configs/main";
      };
    in
    rec {
      packages = forAllSystems ({ pkgs }: (import ./pkgs pkgs.system) pkgs);
      formatter = forAllSystems ({ pkgs }: pkgs.nixfmt-rfc-style);

      overlays = import ./overlays { inherit inputs; };
      nixosModules = import ./modules/nixos;
      homeManagerModules = import ./modules/home-manager;

      nixosConfigurations = {
        # TODO: move Dell laptop from Arch to NixOS
        # kepler = nixpkgs.lib.nixosSystem {
        #   system = "x86_64-linux";
        #   specialArgs = {
        #     inherit inputs outputs vars;
        #   };
        #   modules = [ ./hosts/kepler ];
        # };

        # VM (Nix Build System)
        nixBuilder = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs outputs vars;
          };
          modules = [ ./hosts/nix-builder ];
        };
        # WSL
        syringa = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs outputs vars;
          };
          modules = [ ./hosts/syringa ];
        };
        # Raspberry Pi 3+
        pi = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = {
            inherit inputs outputs vars;
          };
          modules = [ ./hosts/pi ];
        };
        # Banana Pi BPI-R3
        bpi = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = {
            inherit inputs outputs vars;
          };
          modules = [ ./hosts/bpi ];
        };
      };

      darwinConfigurations = {
        # MacBook M1
        laplace = darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = {
            inherit inputs outputs vars;
          };
          modules = [ ./darwin ];
        };
      };

      homeConfigurations = {
        # Steam Deck
        "${vars.user}@companioncube" = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs { system = "x86_64-linux"; };
          extraSpecialArgs = {
            inherit inputs outputs vars;
          };
          modules = [ ./home-manager ];
        };
      };

      images = {
        pi =
          (nixosConfigurations.pi.extendModules {
            modules = [ "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix" ];
          }).config.system.build.sdImage;
        bpi = nixosConfigurations.bpi.config.system.build.sdImage;
      };

      checks = forAllSystems (
        { pkgs }:
        {
          pre-commit-check = inputs.pre-commit-hooks.lib.${pkgs.system}.run {
            src = ./.;
            hooks = {
              nixfmt-rfc-style.enable = true;
            };
          };
          nixvimCheck = nixvim.lib."${pkgs.system}".check.mkTestDerivationFromNixvimModule {
            pkgs = pkgs;
            module = import ./nixvim;
          };
        }
      );

      devShells = forAllSystems (
        { pkgs }:
        {
          default = pkgs.mkShell {
            inherit (self.checks.${pkgs.system}.pre-commit-check) shellHook;
            buildInputs = self.checks.${pkgs.system}.pre-commit-check.enabledPackages;
            packages = with pkgs; [
              inputs.agenix.packages.${system}.default
              nil
              nixfmt-rfc-style
            ];
            env = {
              shell = "zsh";
              NIL_PATH = "${pkgs.nil}/bin/nil";
            };
          };
        }
      );

      templates = {
        empty = {
          path = ./templates/empty;
          description = "Empty development environment";
        };
        go = {
          path = ./templates/go;
          description = "Go development environment";
        };
        latex = {
          path = ./templates/latex;
          description = "LaTeX development environment";
        };
        nix = {
          path = ./templates/nix;
          description = "Nix development environment";
        };
        node = {
          path = ./templates/node;
          description = "Node.js development environment";
        };
        python = {
          path = ./templates/python;
          description = "Python development environment";
        };
        rust = {
          path = ./templates/rust;
          description = "Rust development environment";
        };
        tofu = {
          path = ./templates/tofu;
          description = "OpenTofu development environment";
        };
      };
    };
}

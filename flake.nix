rec {
  description = "Andrew Lubawy's Nix Configs";

  nixConfig = {
    extra-substituters = [
      "https://dlubawy.cachix.org"
    ];
    extra-trusted-public-keys = [ "dlubawy.cachix.org-1:MdCmtrdwBMg8BLku2j4ZSfrzi68SwRKs2aZx7wDOWFc=" ];
  };

  inputs = {
    # Different nixpkgs sources
    nixpkgs.url = "github:NixOS/nixpkgs/release-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-24.11-darwin";

    # System modules
    # FIXME: Change back to darwin branch after upgrade to 25.05
    # changed to nixpkgs branch to bypass issue with nodejs
    darwin = {
      url = "github:dlubawy/nix-darwin/develop";
      inputs.nixpkgs.follows = "nixpkgs";
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
    nix-topology = {
      url = "github:oddlama/nix-topology/f49121cbbf4a86c560638ade406d99ee58deb7aa";
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
      nix-topology,
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
              overlays = [ nix-topology.overlays.default ];
            };
          }
        );

      vars = {
        darwinStateVersion = 4;
        stateVersion = "24.05";
        flake = "github:dlubawy/nix-configs/main";
        admin = (import ./users/drew.nix).nix-configs.users.drew;
        inherit nixConfig;
      };

      mkSystem =
        {
          name,
          system,
        }:
        let
          inherit (nixpkgs) lib;
          isDarwin = lib.strings.hasSuffix "darwin" system;
          systemBuilder = if isDarwin then darwin.lib.darwinSystem else lib.nixosSystem;
          systemModule = if isDarwin then self.darwinModules.default else self.nixosModules.default;
          homeModule = if isDarwin then self.homeManagerModules.darwin else self.homeManagerModules.nixos;
        in
        systemBuilder {
          inherit system;
          specialArgs = {
            inherit inputs outputs vars;
          };
          modules = [
            systemModule
            homeModule
            ./hosts/${name}
          ];
        };
    in
    rec {
      packages = forAllSystems ({ pkgs }: (import ./pkgs pkgs.system) pkgs);
      formatter = forAllSystems ({ pkgs }: pkgs.nixfmt-rfc-style);

      overlays = import ./overlays { inherit inputs; };
      nixosModules = import ./modules/nixos;
      darwinModules = import ./modules/darwin;
      homeManagerModules = import ./modules/home-manager { inherit inputs; };

      nixosConfigurations = {
        # TODO: move Dell laptop from Arch to NixOS
        # kepler = nixpkgs.lib.nixosSystem {
        #   system = "x86_64-linux";
        #   specialArgs = {
        #     inherit inputs outputs vars;
        #   };
        #   modules = [ ./hosts/kepler ];
        # };
        # WSL
        syringa = mkSystem {
          name = "syringa";
          system = "x86_64-linux";
        };
        # Banana Pi BPI-R3
        bpi = mkSystem {
          name = "bpi";
          system = "aarch64-linux";
        };
      };

      darwinConfigurations = {
        # MacBook M1
        laplace = mkSystem {
          name = "laplace";
          system = "aarch64-darwin";
        };
      };

      homeConfigurations = {
        # Steam Deck
        "drew@companioncube" = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs { system = "x86_64-linux"; };
          extraSpecialArgs = {
            inherit inputs outputs vars;
          };
          modules = [
            self.homeManagerModules.default
            ./users/drew.nix
          ];
        };
      };

      images = {
        pi =
          (nixosConfigurations.pi.extendModules {
            modules = [ "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix" ];
          }).config.system.build.sdImage;
        bpi = nixosConfigurations.bpi.config.system.build.sdImage;
      };

      topology = forAllSystems (
        { pkgs }:
        import nix-topology {
          inherit pkgs;
          specialArgs = {
            inherit inputs outputs vars;
          };
          modules = [ ./modules/topology ];
        }
      );

      checks = forAllSystems (
        { pkgs }:
        {
          pre-commit-check = inputs.pre-commit-hooks.lib.${pkgs.system}.run {
            src = ./.;
            hooks = {
              trufflehog = {
                enable = true;
                name = "🔒 Security · Detect hardcoded secrets";
              };
              nixfmt-rfc-style = {
                enable = true;
                name = "🔍 Code Quality · ❄️ Nix · Format";
                after = [ "trufflehog" ];
              };
              flake-checker = {
                enable = true;
                name = "✅ Data & Config Validation · ❄️ Nix · Flake checker";
                args = [
                  "--check-supported"
                  "false"
                ];
                after = [ "nixfmt-rfc-style" ];
              };
              check-yaml = {
                enable = true;
                name = "✅ Data & Config Validation · YAML · Lint";
                after = [ "nixfmt-rfc-style" ];
              };
              mdformat = {
                enable = true;
                name = "📝 Docs · Markdown · Format";
                after = [
                  "flake-checker"
                  "check-yaml"
                ];
              };
              checkmake = {
                enable = true;
                name = "🐮 Makefile · Lint";
                after = [ "mdformat" ];
              };
              check-case-conflicts = {
                enable = true;
                name = "📁 Filesystem · Check case sensitivity";
                after = [ "checkmake" ];
              };
              check-symlinks = {
                enable = true;
                name = "📁 Filesystem · Check symlinks";
                after = [ "checkmake" ];
              };
              check-merge-conflicts = {
                enable = true;
                name = "🌳 Git Quality · Detect conflict markers";
                after = [
                  "check-symlinks"
                  "check-case-conflicts"
                ];
              };
              forbid-new-submodules = {
                enable = true;
                name = "🌳 Git Quality · Prevent submodule creation";
                after = [
                  "check-symlinks"
                  "check-case-conflicts"
                ];
              };
              no-commit-to-branch = {
                enable = true;
                name = "🌳 Git Quality · Protect main branch";
                settings.branch = [ "main" ];
                stages = [ "pre-push" ];
                after = [
                  "check-symlinks"
                  "check-case-conflicts"
                ];
              };
              check-added-large-files = {
                enable = true;
                name = "🌳 Git Quality · Block large file commits";
                args = [ "--maxkb=5000" ];
                after = [
                  "check-symlinks"
                  "check-case-conflicts"
                ];
              };
              commitizen = {
                enable = true;
                name = "🌳 Git Quality · Validate commit message";
                stages = [ "commit-msg" ];
                after = [
                  "check-symlinks"
                  "check-case-conflicts"
                ];
              };
            };
          };
          nixvimCheck = nixvim.lib."${pkgs.system}".check.mkTestDerivationFromNixvimModule {
            inherit pkgs;
            module = import ./modules/nixvim;
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
              (writeScriptBin "sync-flake-inputs" ''
                gitRoot="$(${pkgs.git}/bin/git rev-parse --show-toplevel)"
                if [ -z "$gitRoot" ]; then
                  echo "Not a git project"
                  exit 1
                fi

                version="$1"
                if [ -z "$version" ]; then
                  version="$(${pkgs.gnugrep}/bin/grep --color=never -o 'release-[0-9]\+.[0-9]\+' "$gitRoot"/flake.nix | head -n 1)"
                  if [ -z "$version" ]; then
                    echo "Could not determine root flake version"
                    exit 1
                  fi
                fi

                for template in "$gitRoot"/templates/*; do
                  pushd "$template"
                  ${pkgs.gnused}/bin/sed -i "s/release-[0-9]\+.[0-9]\+/release-''${version/*-}/g" ./flake.nix
                  cp ../../flake.lock ./flake.lock
                  nix flake lock
                  popd
                done
              '')
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
        deno = {
          path = ./templates/deno;
          description = "Deno development environment";
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

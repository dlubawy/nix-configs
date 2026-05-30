rec {
  description = "Andrew Lubawy's Nix Configs";

  nixConfig = {
    extra-substituters = [
      "https://dlubawy.cachix.org"
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "dlubawy.cachix.org-1:MdCmtrdwBMg8BLku2j4ZSfrzi68SwRKs2aZx7wDOWFc="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    # Different nixpkgs sources
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";

    # System modules
    darwin = {
      url = "github:dlubawy/nix-darwin/develop-26.05";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-wsl = {
      # FIXME: Swap when upstream is updated
      # url = "github:nix-community/NixOS-WSL/release-26.05";
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-sbc = {
      url = "github:nakato/nixos-sbc/e7a298859841bde2a572a12227a5778ad1d9f771";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Supporting modules
    nixvim = {
      url = "github:nix-community/nixvim/nixos-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:dlubawy/agenix/launchd_settings";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    git-hooks = {
      url = "github:cachix/git-hooks.nix/3cfd774b0a530725a077e17354fbdb87ea1c4aad";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-topology = {
      url = "github:oddlama/nix-topology/ca0a602f650306d00d6f3e3c76d0f4c48a5c5adc";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko/v1.13.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    preservation = {
      url = "github:nix-community/preservation/93416f4614ad2dfed5b0dcf12f27e57d27a5ab11";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-darwin,
      darwin,
      home-manager,
      nixvim,
      agenix,
      git-hooks,
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

      forSystemList =
        let
          inherit (nixpkgs) lib;
        in
        systemList: f:
        lib.genAttrs systemList (
          system:
          let
            systemPkgs = if (lib.hasSuffix system "darwin") then nixpkgs-darwin else nixpkgs;
          in
          f {
            pkgs = import systemPkgs {
              inherit system;
              config.allowUnfree = true;
              overlays = [ nix-topology.overlays.default ];
            };
          }
        );

      forAllSystems = forSystemList systems;

      vars = {
        darwinStateVersion = 7;
        stateVersion = "26.05";
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
          homeModule = if isDarwin then self.homeModules.darwin else self.homeModules.nixos;
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

        # GMTtec G9
        lil-nas = mkSystem {
          name = "lil-nas";
          system = "x86_64-linux";
        };
      };
    in
    {
      packages = forAllSystems ({ pkgs }: (import ./pkgs pkgs.stdenv.hostPlatform.system) pkgs);
      formatter = forAllSystems ({ pkgs }: pkgs.nixfmt);

      overlays = import ./overlays { inherit inputs; };
      nixosModules = import ./modules/nixos;
      darwinModules = import ./modules/darwin;
      homeModules = import ./modules/home-manager { inherit inputs; };

      nixosConfigurations = nixosConfigurations;

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
            self.homeModules.default
            ./homes/companioncube
          ];
        };

        # Android Virtualization Framework (AVF) Linux terminal
        "droid@debian" = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs { system = "aarch64-linux"; };
          extraSpecialArgs = {
            inherit inputs outputs vars;
          };
          modules = [
            self.homeModules.default
            ./homes/debian
          ];
        };
      };

      images = {
        pi =
          (nixosConfigurations.pi.extendModules {
            modules = [ "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix" ];
          }).config.system.build.sdImage;
        bpi = nixosConfigurations.bpi.config.system.build.sdImage;
        nixos-iso-installer = forSystemList [ "aarch64-linux" "x86_64-linux" ] (
          { pkgs }:
          let
            inherit (nixpkgs) lib;
          in
          (lib.nixosSystem {
            inherit (pkgs.stdenv.hostPlatform) system;
            specialArgs = {
              inherit inputs outputs vars;
            };
            modules = [
              self.nixosModules.installer
            ];
          }).config.system.build.isoImage
        );
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
          pre-commit-check = git-hooks.lib.${pkgs.stdenv.hostPlatform.system}.run {
            src = builtins.path {
              path = ./.;
              name = "nix-configs";
            };
            package = pkgs.prek;
            hooks = {
              trufflehog = {
                enable = true;
                name = "🔒 Security · Detect hardcoded secrets";
              };
              nixfmt = {
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
                after = [ "nixfmt" ];
              };
              check-yaml = {
                enable = true;
                name = "✅ Data & Config Validation · YAML · Lint";
                after = [ "nixfmt" ];
              };
              mdformat = {
                enable = true;
                name = "📝 Docs · Markdown · Format";
                after = [
                  "flake-checker"
                  "check-yaml"
                ];
              };
              just =
                let
                  package = pkgs.just;
                in
                {
                  enable = true;
                  package = package;
                  name = "🤖 Justfile · Format";
                  entry = "${package}/bin/just --fmt --unstable";
                  files = "^justfile$";
                  pass_filenames = false;
                  after = [ "mdformat" ];
                };
              check-case-conflicts = {
                enable = true;
                name = "📁 Filesystem · Check case sensitivity";
                after = [ "just" ];
              };
              check-symlinks = {
                enable = true;
                name = "📁 Filesystem · Check symlinks";
                after = [ "just" ];
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
          nixvimCheck = (
            nixvim.lib."${pkgs.stdenv.hostPlatform.system}".check.mkTestDerivationFromNixvimModule {
              inherit pkgs;
              module = import ./modules/nixvim;
            }
          );
        }
      );

      devShells = forAllSystems (
        { pkgs }:
        {
          default =
            let
              inherit (pkgs) writeShellApplication stdenv;
              inherit (self.checks.${pkgs.stdenv.hostPlatform.system}.pre-commit-check) enabledPackages shellHook;
            in
            pkgs.mkShell {
              inherit shellHook;
              buildInputs = (builtins.attrValues { inherit (pkgs) prek; }) ++ enabledPackages;
              packages = [
                agenix.packages.${stdenv.hostPlatform.system}.default
                (writeShellApplication {
                  name = "sync-flake-inputs";
                  runtimeInputs = builtins.attrValues {
                    inherit (pkgs)
                      git
                      gnugrep
                      gnused
                      ;
                  };
                  text = ''
                    gitRoot="$(git rev-parse --show-toplevel)"
                    if [ -z "$gitRoot" ]; then
                      echo "Not a git project"
                      exit 1
                    fi

                    version="''${1:-""}"
                    if [ -z "$version" ]; then
                      version="$(grep --color=never -o 'nixos-[0-9]\+.[0-9]\+' "$gitRoot"/flake.nix | head -n 1)"
                      if [ -z "$version" ]; then
                        echo "Could not determine root flake version"
                        exit 1
                      fi
                    fi

                    for template in "$gitRoot"/templates/*; do
                      pushd "$template"
                      sed -i "s/nixos-[0-9]\+.[0-9]\+/nixos-''${version/*-}/g" ./flake.nix
                      cp ../../flake.lock ./flake.lock
                      nix flake lock
                      popd
                    done
                  '';
                })
              ]
              ++ (builtins.attrValues {
                inherit (pkgs)
                  just
                  nil
                  nixfmt
                  nixos-rebuild-ng
                  ;
              });
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

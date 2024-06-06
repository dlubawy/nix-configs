{
  description = "Andrew Lubawy's Nix Configs";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-24.05";
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-24.05-darwin";
    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      darwin,
      home-manager,
      nixvim,
      ...
    }@inputs:
    let
      inherit (self) outputs;

      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      forEachSupportedSystem =
        f: nixpkgs.lib.genAttrs supportedSystems (system: f { pkgs = import nixpkgs { inherit system; }; });

      vars = {
        name = "Andrew Lubawy";
        email = "andrew@andrewlubawy.com";
        user = "drew";
      };
    in
    {
      darwinConfigurations = {
        laplace = darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = {
            inherit inputs outputs vars;
          };
          modules = [ ./darwin ];
        };
      };

      checks = forEachSupportedSystem (
        { pkgs }:
        {
          nixvimCheck = nixvim.lib."${pkgs.system}".check.mkTestDerivationFromNixvimModule {
            pkgs = pkgs;
            module = import ./nixvim;
          };
        }
      );
      devShells = forEachSupportedSystem (
        { pkgs }:
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              nil
              nixfmt-rfc-style
            ];
            env = {
              shell = "zsh";
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

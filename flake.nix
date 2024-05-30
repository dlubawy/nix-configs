{
  description = "Andrew Lubawy's Nix Configs";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
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
      vars = {
        name = "Andrew Lubawy";
        email = "andrew@andrewlubawy.com";
        user = "drew";
        editor = "nvim";
      };
    in
    {
      darwinConfigurations = {
        laplace = darwin.lib.darwinSystem {
          specialArgs = {
            inherit inputs outputs vars;
          };
          modules = [ ./darwin/configuration.nix ];
        };
      };
    };
}

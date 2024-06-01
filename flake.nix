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
      vars = {
        name = "Andrew Lubawy";
        email = "andrew@andrewlubawy.com";
        user = "drew";
      };
    in
    {
      darwinConfigurations = {
        laplace = darwin.lib.darwinSystem {
          specialArgs = {
            inherit inputs outputs vars;
          };
          modules = [ ./darwin ];
        };
      };
    };
}

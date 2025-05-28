# Add your reusable home-manager modules to this directory, on their own file (https://nixos.wiki/wiki/Module).
# These should be stuff you would like to share with others, not your personal configurations.
{
  # List your module files here
  default = import ./home-manager.nix;
  darwin =
    {
      inputs,
      outputs,
      vars,
      ...
    }:
    {
      imports = [ inputs.home-manager.darwinModules.home-manager ];

      config = {
        home-manager = {
          extraSpecialArgs = {
            inherit inputs outputs vars;
          };
          users.${vars.user} = import ./home-manager.nix;
          useUserPackages = true;
          useGlobalPkgs = true;
        };
      };
    };
  nixos =
    {
      inputs,
      outputs,
      vars,
      ...
    }:
    {
      imports = [ inputs.home-manager.nixosModules.home-manager ];

      config = {
        home-manager = {
          extraSpecialArgs = {
            inherit inputs outputs vars;
          };
          users.${vars.user} = import ./home-manager.nix;
          useUserPackages = true;
          useGlobalPkgs = true;
        };
      };
    };
}

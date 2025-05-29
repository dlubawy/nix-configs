# Add your reusable home-manager modules to this directory, on their own file (https://nixos.wiki/wiki/Module).
# These should be stuff you would like to share with others, not your personal configurations.
{ inputs, ... }:
{
  # List your module files here
  default = import ./home-manager.nix;
  darwin = {
    imports = [
      inputs.home-manager.darwinModules.home-manager
      ./system.nix
    ];
  };
  nixos = {
    imports = [
      inputs.home-manager.nixosModules.home-manager
      ./system.nix
    ];
  };
}

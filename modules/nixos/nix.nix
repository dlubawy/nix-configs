{ outputs, vars, ... }:
{
  nixpkgs = {
    overlays = builtins.attrValues outputs.overlays;
  };

  nix = {
    enable = true;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    optimise.automatic = true;
    settings = {
      experimental-features = "nix-command flakes";
      substituters = vars.nixConfig.extra-substituters;
      trusted-public-keys = vars.nixConfig.extra-trusted-public-keys;
    };
  };
}

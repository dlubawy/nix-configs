{
  lib,
  outputs,
  vars,
  ...
}:
let
  inherit (lib) mkIf;
in
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
      substituters = mkIf (builtins.hasAttr "nixConfig" vars) vars.nixConfig.extra-substituters;
      trusted-public-keys = mkIf (builtins.hasAttr "nixConfig" vars) vars.nixConfig.extra-trusted-public-keys;
    };
  };
}

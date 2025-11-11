{
  lib,
  config,
  inputs,
  outputs,
  vars,
  ...
}:
let
  nixConfigUsers = config.nix-configs.users;
in
{
  options = {
    home-manager.gui.enable = lib.mkOption {
      default = true;
      type = lib.types.bool;
      description = "Enable GUI applications";
    };
  };
  config = {
    home-manager = {
      extraSpecialArgs = {
        inherit inputs outputs vars;
      };
      users = (
        lib.concatMapAttrs (name: value: {
          ${name} = lib.mkMerge [
            (import ./home-manager.nix)
            {
              nix-configs.users.${name} = value;
              gui.enable = lib.mkDefault config.home-manager.gui.enable;
            }
          ];
        }) nixConfigUsers
      );
      useUserPackages = true;
      useGlobalPkgs = true;
    };
  };
}

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
    home-manager = {
      gui.enable = lib.mkOption {
        default = (!config.home-manager.minimal);
        type = lib.types.bool;
        description = "Enable GUI applications";
      };
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
              minimal = lib.mkDefault config.home-manager.minimal;
            }
          ];
        }) nixConfigUsers
      );
      useUserPackages = true;
      useGlobalPkgs = true;
      backupFileExtension = "bak";
    };
  };
}

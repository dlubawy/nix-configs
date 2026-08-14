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
        default = (!config.home-manager.minimalConfiguration.enable);
        type = lib.types.bool;
        description = "Enable GUI applications";
      };
      minimalConfiguration.enable = lib.mkEnableOption "Enable minimal home configurations";
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
              minimal.enable = lib.mkDefault config.home-manager.minimalConfiguration.enable;
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

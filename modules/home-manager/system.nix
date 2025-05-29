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
          }
        ];
      }) nixConfigUsers
    );
    useUserPackages = true;
    useGlobalPkgs = true;
  };
}

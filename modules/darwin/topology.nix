{
  config,
  lib,
  options,
  inputs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    types
    mkOption
    mkDefault
    ;
  topologyModule = (import inputs.nix-topology.nixosModules.default { inherit config lib options; });
  topologyLib = builtins.head (
    builtins.filter (x: builtins.hasAttr "lib" x) topologyModule.config.contents
  );
in
{
  options = {
    topology = {
      enable = mkEnableOption "Enable system in topology view";
      self = mkOption {
        description = "Topology device attributes";
        type = types.attrs;
      };
    };
  };

  config = {
    lib.topology = topologyLib.lib.topology;
    topology.self = mkDefault { };
  };
}

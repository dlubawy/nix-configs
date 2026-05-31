{
  pkgs,
  lib,
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
  topologyModule = (import inputs.nix-topology.sourceInfo.outPath { inherit pkgs; });
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
    lib.topology = topologyModule.config.lib.topology;
    topology.self = mkDefault { };
  };
}

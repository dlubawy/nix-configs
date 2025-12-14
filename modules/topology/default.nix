{
  lib,
  config,
  outputs,
  ...
}:
let
  inherit (lib)
    filterAttrs
    concatMapAttrs
    strings
    lists
    ;
  inherit (config.lib.topology) mkSwitch mkDevice;
  darwinConfigurations = filterAttrs (
    _: value: (builtins.hasAttr "topology" value.config) && value.config.topology.enable
  ) outputs.darwinConfigurations;
in
{
  config = {
    lib.helpers = {
      getAddress = interface: (builtins.head interface.addresses);
      getJellyfinPort =
        node: (lists.last (strings.split ":" node.services.jellyfin.details."listen.http".text));
    };

    nixosConfigurations = filterAttrs (
      _: value: (builtins.hasAttr "topology" value.config) && value.config.topology.enable
    ) outputs.nixosConfigurations;

    icons = {
      interfaces = {
        tailscale.file = ./tailscale.png;
      };
      devices = {
        nix-darwin.file = ./nix-darwin.png;
      };
    };

    networks = {
      tailscale = {
        name = "Tailscale Network";
        cidrv4 = "100.64.0.0/10";
      };
    };

    nodes = {
      tailscale = mkSwitch "Tailscale" {
        info = "Tailscale Switching Server";
        image = ./tailscale.png;
        interfaceGroups = [ [ "lan" ] ];
        interfaces.lan = {
          renderer.hidePhysicalConnections = true;
          network = "tailscale";
        };
      };
    }
    // (concatMapAttrs (name: value: {
      "${name}" = mkDevice name value.config.topology.self;
    }) darwinConfigurations);
  };
}

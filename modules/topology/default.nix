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
    lib.helpers = rec {
      hasNode = node: (builtins.hasAttr node config.nodes);
      hasService =
        node: service: ((hasNode node) && (builtins.hasAttr service config.nodes.${node}.services));
      hasInterface =
        node: interface: ((hasNode node) && (builtins.hasAttr interface config.nodes.${node}.interfaces));
      getHomeDomain =
        homeNode: proxy:
        (if (hasService homeNode proxy) then config.nodes.${homeNode}.services.${proxy}.info else "");
      getAddress =
        node: interface:
        (
          if (hasInterface node interface) then
            (builtins.head config.nodes.${node}.interfaces.${interface}.addresses)
          else
            ""
        );
      getMac =
        node: interface:
        (if (hasInterface node interface) then config.nodes.${node}.interfaces.${interface}.mac else "");
      getJellyfinPort =
        node:
        if (hasService node "jellyfin") then
          (lists.last (strings.split ":" config.nodes.${node}.services.jellyfin.details."listen.http".text))
        else
          "";
      getPrometheusPort =
        node:
        if (hasService node "prometheus") then
          (lists.last (strings.split ":" config.nodes.${node}.services.prometheus.details.listen.text))
        else
          "";
      getGrafanaPort =
        node:
        if (hasService node "grafana") then
          (lists.last (strings.split ":" config.nodes.${node}.services.grafana.details.listen.text))
        else
          "";
      getLokiPort =
        node:
        if (hasService node "loki") then
          (lists.last (strings.split ":" config.nodes.${node}.services.loki.details.listen.text))
        else
          "";
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

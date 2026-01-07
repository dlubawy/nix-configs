# Topology Module

This module provides network topology visualization using [nixos-topology](https://github.com/oddlama/nix-topology). It generates visual diagrams of the network infrastructure including hosts, services, and network connections.

## Purpose

The topology module:

- Visualizes network infrastructure and service relationships
- Documents the physical and logical network layout
- Shows service dependencies and connections
- Provides auto-generated topology diagrams for documentation

## Usage

Enable topology in host configurations:

```nix
{
  topology.enable = true;
  topology.self = {
    # Device-specific topology configuration
  };
}
```

Generate topology diagrams:

```bash
make topology
# or
nix build .#topology.<system>.config.output
```

## Features

- **Network Visualization**: Shows network topology with switches and connections
- **Service Mapping**: Visualizes services running on each host
- **Custom Icons**: Includes custom icons for Tailscale, nix-darwin, and Collabora
- **Helper Functions**: Utilities for querying network addresses, ports, and services
- **Multiple Views**: Generates both main and network-specific topology views

## Configuration

The module provides helper functions for topology configuration:

- `hasNode`: Check if a node exists
- `hasService`: Check if a service exists on a node
- `hasInterface`: Check if a network interface exists
- `getAddress`: Get IP address of a node's interface
- `getMac`: Get MAC address of an interface
- `getJellyfinPort`: Get Jellyfin service port
- `getPrometheusPort`: Get Prometheus service port
- `getGrafanaPort`: Get Grafana service port
- `getLokiPort`: Get Loki service port

## Custom Icons

The module includes custom icons for:

- **Tailscale**: VPN network visualization
- **nix-darwin**: macOS hosts
- **Collabora Online**: Document editing service

## Networks

Pre-configured networks:
- **Tailscale**: VPN mesh network (100.64.0.0/10)

## Output

Topology diagrams are generated as SVG files:
- `assets/topology-main.svg`: Main topology view
- `assets/topology-network.svg`: Network-focused view

These are referenced in host README files for visual documentation.

## Files

- `default.nix`: Main topology configuration
- `tailscale.png`: Tailscale icon
- `nix-darwin.png`: nix-darwin icon
- `code-logo.png`: Collabora Online icon

## Related Documentation

- See [nixos-topology documentation](https://github.com/oddlama/nix-topology)
- See host READMEs for examples: [bpi](../../hosts/bpi/README.md), [lil-nas](../../hosts/lil-nas/README.md)
- View generated topology diagrams in the [assets](../../assets) directory

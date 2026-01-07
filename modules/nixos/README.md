# NixOS Module

This module provides NixOS system configuration with security, user management, state preservation, and networking features. It serves as the base for all NixOS hosts in this configuration.

## Purpose

The NixOS module sets up a complete Linux system configuration including:

- System-level security (secure boot with lanzaboote)
- User and group management
- State preservation for ephemeral root filesystems
- Tailscale VPN integration
- Nix configuration and optimization
- Network topology integration

## Usage

Import this module in your NixOS host configuration:

```nix
{
  imports = [
    inputs.nix-configs.nixosModules.default
  ];
  
  networking.hostName = "hostname";
}
```

## Configuration Options

- `topology.enable`: Enable system in network topology visualization
- `boot.secure.enable`: Enable secure boot using lanzaboote (requires `sudo sbctl create-keys`)

## Features

- **Secure Boot**: Optional secure boot support via lanzaboote
- **User Management**: Custom user and group configuration with shadow password support
- **State Preservation**: Persist important state across ephemeral root reboots
- **Tailscale Integration**: VPN networking with automatic configuration
- **Nix Optimization**: Auto-upgrade, garbage collection, and optimized settings
- **Topology Support**: Network visualization via nixos-topology

## Sub-Modules

- `nix.nix`: Nix daemon configuration and optimization
- `users.nix`: User and group management for NixOS
- `preservation.nix`: State persistence for ephemeral root setups
- `tailscale.nix`: Tailscale VPN configuration
- `installer.nix`: ISO installer configuration

## Files

- `nixos.nix`: Main module configuration
- `default.nix`: Module exports
- `installer.nix`: ISO installation image configuration
- `nix.nix`: Nix-specific settings
- `preservation.nix`: Impermanence/state preservation
- `tailscale.nix`: Tailscale VPN setup
- `users.nix`: User management

## Related Documentation

- See [hosts/bpi/README.md](../../hosts/bpi/README.md) for router/network appliance setup
- See [hosts/lil-nas/README.md](../../hosts/lil-nas/README.md) for NAS server setup
- See [hosts/syringa/README.md](../../hosts/syringa/README.md) for WSL setup
- See [modules/home-manager](../home-manager) for user-level configuration

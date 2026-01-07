# Darwin Module

This module provides macOS (Darwin) system configuration for nix-darwin installations. It configures system-level settings, security, networking, and integrates with Home Manager for user management.

## Purpose

The Darwin module sets up a complete macOS system configuration including:

- System-level security settings (firewall, file vault)
- Networking configuration
- Nix and Homebrew integration
- User management with admin/regular user separation
- Dock and launcher settings
- Keyboard and trackpad configuration
- Network topology integration

## Usage

Import this module in your host configuration:

```nix
{
  imports = [
    inputs.nix-configs.darwinModules.default
  ];
  
  systemName = "hostname";
}
```

## Configuration Options

- `systemName`: System name for deriving admin username and computer hostname

## Features

- **Security**: Firewall enabled by default, stealth mode, signed packages only
- **Nix Configuration**: Optimized settings, auto-upgrade, garbage collection
- **Homebrew Integration**: Mac App Store and Homebrew package management
- **User Management**: Custom user configuration with admin separation
- **System Preferences**: Dock, keyboard, trackpad, and other macOS settings
- **Topology Integration**: Network visualization support via nixos-topology

## Files

- `darwin.nix`: Main module configuration
- `users.nix`: User management for Darwin
- `topology.nix`: Network topology integration
- `default.nix`: Module export

## Related Documentation

- See [hosts/laplace/README.md](../../hosts/laplace/README.md) for an example macOS installation
- See [modules/home-manager](../home-manager) for user-level configuration

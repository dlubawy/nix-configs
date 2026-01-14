[![Cache 📝](https://github.com/dlubawy/nix-configs/actions/workflows/cache.yaml/badge.svg)](https://github.com/dlubawy/nix-configs/actions/workflows/cache.yaml)
[![Format 🔎](https://github.com/dlubawy/nix-configs/actions/workflows/format.yaml/badge.svg)](https://github.com/dlubawy/nix-configs/actions/workflows/format.yaml)
[![Update ⬆️](https://github.com/dlubawy/nix-configs/actions/workflows/update.yaml/badge.svg)](https://github.com/dlubawy/nix-configs/actions/workflows/update.yaml)

# nix-configs

My personal Nix configurations for managing multiple systems using [NixOS](https://nixos.org/) and [nix-darwin](https://github.com/LnL7/nix-darwin). This repository provides declarative configuration for workstations, servers, and network infrastructure.

## Overview

This configuration manages:

- **NixOS systems**: Router (Banana Pi), NAS server (GMKtec G9), WSL
- **macOS systems**: Development workstation (MacBook Pro M1)
- **User environments**: Dotfiles and applications via Home Manager
- **Network services**: Nextcloud, Jellyfin, Grafana, Prometheus, Loki
- **Network infrastructure**: Router with VLANs, firewall, and monitoring

## Getting Started

To use these configurations:

1. **Review the documentation** for your target system in the [Hosts](#hosts) or [Homes](#homes) section
1. **Define your users** in `./users` following the [nix-configs module](./modules/nix-configs/README.md) schema
1. **Update `vars` in `flake.nix`** with your admin user email
1. **Configure secrets** using `agenix` for passwords and sensitive data
1. **Build and deploy** using the commands specific to your host or home

Each host and home configuration has detailed installation instructions in its README.

## Notes

These configurations make use of personal preferences. I have forked some tools and made personal edits which may make this unstable:

- `nix-darwin`: I added additional user configuration management and fixed some multi-user issues in the system. This was done in a heavy-handed manner and so will likely not be supported upstream. This may change as upstream improves on these issues.
- `agenix`: Wanted to add armor output support for better git visibility. Also needed to fix `ageBin` for Darwin configuration.

## Hosts

- Banana Pi BPI-R3: [`bpi`](./hosts/bpi/README.md) - Router and network infrastructure
- GMKtec G9: [`lil-nas`](./hosts/lil-nas/README.md) - NAS server with Nextcloud, Jellyfin, and monitoring
- MacBook Pro M1: [`laplace`](./hosts/laplace/README.md) - macOS development workstation
- WSL: [`syringa`](./hosts/syringa/README.md) - Windows Subsystem for Linux

Hosts import reusable system configuration modules based on the type of system being configured:

- Darwin: [`./modules/darwin`](./modules/darwin/README.md)
- Linux: [`./modules/nixos`](./modules/nixos/README.md)

All hosts import the Home Manager module ([`./modules/home-manager`](./modules/home-manager/README.md)). This module brings in reusable configurations to be applied for each defined user in a host.

## Homes

Standalone home-manager configurations for systems not managed by NixOS or nix-darwin:

- Steam Deck: [`companioncube`](./homes/companioncube/README.md) - Portable gaming device
- Android AVF: [`debian`](./homes/debian/README.md) - Android Virtualization Framework Linux terminal

Each home configuration has its own README with installation and usage instructions.

## Modules

Reusable NixOS and nix-darwin modules provide the building blocks for host configurations:

- [`darwin`](./modules/darwin/README.md): macOS system configuration via nix-darwin
- [`home-manager`](./modules/home-manager/README.md): User-level dotfiles and application configuration
- [`nix-configs`](./modules/nix-configs/README.md): Common user definition schema
- [`nixos`](./modules/nixos/README.md): NixOS system configuration
- [`nixvim`](./modules/nixvim/README.md): Neovim IDE configuration
- [`topology`](./modules/topology/README.md): Network topology visualization

Each module has its own README with detailed documentation on its purpose and usage.

## Users

Users are defined in the [`./users`](./users) directory using the schema from the [`nix-configs`](./modules/nix-configs/README.md) module. The default configuration imports all users, but hosts can selectively import individual users as needed.

The admin user is specified in `vars` within `flake.nix`. **You should modify this user if copying this repository.**

### Password Management

Default passwords for users are set differently by platform:

- **Darwin**: Defaults to the user's configuration `name`
- **NixOS**: Set via `initialHashedPassword` or `hashedPasswordFile`

If `mutableUsers` is enabled in the host configuration, passwords may be changed from their initial values.

#### NixOS Shadow Files

The `users.shadow.enable` option moves password management into individually managed `$HOME/.shadow` files using the `nixos-passwd` script from the `nixos-password` package. When a `/persist` mount is enabled, shadow files are created in `/persist/$HOME/.shadow` for each managed user.

## Templates

Development environment templates are available for quick project setup. Initialize a new project with:

```bash
nix flake init --template github:dlubawy/nix-configs/main#[template]
```

Available templates: `deno`, `go`, `latex`, `nix`, `python`, `rust`, `tofu`, and `empty`.

# Home Manager Module

This module provides user-level configuration using Home Manager. It manages dotfiles, shell configuration, development tools, and GUI applications for individual users across all systems.

## Purpose

The Home Manager module configures per-user settings including:

- Shell environment (zsh with plugins and aliases)
- Terminal emulator (Alacritty)
- Editor (Neovim via nixvim)
- Version control (Git, GPG)
- SSH configuration
- Terminal multiplexer (tmux)
- Development scripts and utilities
- GUI applications (optional)

## Usage

This module is automatically imported by host configurations. Users are defined in the `./users` directory and the module applies appropriate configurations based on whether GUI is enabled.

In a host configuration:

```nix
{
  home-manager.gui.enable = true;  # or false for headless systems
}
```

## Configuration Options

- `gui.enable`: Enable GUI applications (default: true)
  - When enabled: Alacritty, Hyprland (Linux only), qtpass
  - When disabled: Terminal-only configuration

## Features

- **Shell (zsh)**: Extensive zsh configuration with plugins, aliases, and shell integrations
- **Terminal (Alacritty)**: GPU-accelerated terminal with Catppuccin theme
- **Editor (Neovim)**: Full IDE-like configuration via nixvim module
- **Git**: Git configuration with GPG signing support
- **SSH**: SSH client configuration with host definitions
- **Starship**: Cross-shell prompt with git integration
- **Tmux**: Terminal multiplexer with custom keybindings
- **Scripts**: Custom utility scripts (weather, colors, git helpers, etc.)
- **Hyprland**: Wayland compositor (Linux only)
- **Password Management**: qtpass for password-store (pass) integration

## Sub-Modules

Each configuration area is separated into its own file:

- `agenix.nix`: Age encryption for secrets
- `alacritty.nix`: Terminal emulator
- `git.nix`: Git version control
- `gpg.nix`: GPG key management
- `hyprland.nix`: Wayland compositor
- `nixvim.nix`: Neovim configuration integration
- `qtpass.nix`: Password manager GUI
- `scripts/`: Custom utility scripts
- `ssh.nix`: SSH client configuration
- `starship.nix`: Shell prompt
- `system.nix`: System integration for both Darwin and NixOS
- `tmux.nix`: Terminal multiplexer
- `user.nix`: User-specific settings and packages
- `zsh.nix`: Zsh shell configuration

## Files

See individual `.nix` files in this directory for specific configurations. The `scripts/` subdirectory contains custom shell scripts packaged as derivations.

## Related Documentation

- See [modules/nixvim](../nixvim) for detailed Neovim configuration
- See host READMEs for how Home Manager is integrated per-system

# Android Virtualization Framework (AVF) Linux Terminal (debian)

Standalone home-manager configuration for Android devices using the AVF Linux terminal.

This configuration is customized for the Android environment with:

- GUI applications disabled
- Terminal-only setup
- Custom tmux keybinding (prefix: `b` instead of `a`)
- Nixvim image plugin disabled

## Installation

1. [Install Nix](https://nix.dev/install-nix#install-nix) on the AVF Linux terminal
2. Clone this repository
3. Build and activate the configuration:

   ```bash
   nix run home-manager -- switch --flake github:dlubawy/nix-configs/main#droid@debian
   ```

## Updates

To update the configuration:

```bash
home-manager switch --flake github:dlubawy/nix-configs/main#droid@debian
```


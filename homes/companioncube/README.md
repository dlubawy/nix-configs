# Steam Deck (companioncube)

Standalone home-manager configuration for the Steam Deck.

## Installation

1. [Install Nix](https://nix.dev/install-nix#install-nix)
2. Clone this repository
3. Build and activate the configuration:

   ```bash
   nix run home-manager -- switch --flake github:dlubawy/nix-configs/main#drew@companioncube
   ```

## Updates

To update the configuration:

```bash
home-manager switch --flake github:dlubawy/nix-configs/main#drew@companioncube
```


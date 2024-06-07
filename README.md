# nix-configs
My personal Nix configurations

## Setup
### macOS
* [Install Nix](https://nix.dev/install-nix#install-nix)
* Clone repo: `git clone https://github.com/dlubawy/nix-configs.git`
* Edit `vars` in `flake.nix` to use your desired name, email, and user
* Run `make laplace`

### Templates
Use any template to create a nix flake based development environment with:
```
nix flake init --template github:dlubawy/nix-configs/main#[template]
```

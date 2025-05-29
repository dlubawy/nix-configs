[![Cache 📝](https://github.com/dlubawy/nix-configs/actions/workflows/cache.yaml/badge.svg)](https://github.com/dlubawy/nix-configs/actions/workflows/cache.yaml)
[![Format 🔎](https://github.com/dlubawy/nix-configs/actions/workflows/format.yaml/badge.svg)](https://github.com/dlubawy/nix-configs/actions/workflows/format.yaml)
[![Update ⬆️](https://github.com/dlubawy/nix-configs/actions/workflows/update.yaml/badge.svg)](https://github.com/dlubawy/nix-configs/actions/workflows/update.yaml)

# nix-configs

My personal Nix configurations.

## Notes

These configurations make use of personal preferences. I have forked some tools and made personal edits which may make this unstable:

- `nix-darwin`: I added additional user configuration management and fixed some multi-user issues in the system. This was done in a heavy-handed manner and so will likely not be supported upstream. This may change as upstream improves on these issues.
- `agenix`: Wanted to add armor output support for better git visibility. Also needed to fix `ageBin` for Darwin configuration.

## Hosts

- Banana Pi BPI-R3: [`bpi`](./hosts/bpi/README.md)
- MacBook Pro M1: [`laplace`](./hosts/laplace/README.md)
- WSL: [`syringa`](./hosts/syringa/README.md)

Hosts import reusable system configuration modules based on the type of system being configured:

- Darwin: `./modules/darwin`
- Linux: `./modules/nixos`

All hosts import the Home Manager module (`./modules/home-manager`). This module brings in reusable configurations to be applied for each defined user in a host.

Users are defined in the `./users` module where the default imports all users, but hosts can selectively choose to import individual users as needed. An admin is specified in the `vars` within `flake.nix`. You should modify this user if copying this repo.

## Templates

Use any template to create a nix flake based development environment with:

```
nix flake init --template github:dlubawy/nix-configs/main#[template]
```

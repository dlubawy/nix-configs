# Repository Guidelines

This document provides a quick reference for contributors working on this
Nix‑flake based repository. It covers the layout, build workflow, coding
style, testing, and PR etiquette.

## Project Structure & Module Organization

```
├── flake.nix          # top‑level flake definition
├── flake.lock         # pinned inputs
├── modules/           # reusable Nix modules (darwin, home‑manager, nixos, etc.)
├── pkgs/              # custom packages (e.g. codex‑universal, prometheus‑…)
├── overlays/          # custom overlays for third‑party packages
├── hosts/             # host‑specific configurations (bpi, laplace, syringa)
├── templates/         # project templates for new repos
└── secrets/           # age‑encrypted secrets (never commit plain text)
```

All host configurations are built with `nix build .#<host>.<system>.config.output`.
Modules are imported via `inputs.self.modules.<name>`.

## Build, Test, and Development Commands

| Command | Purpose | Example |
|---------|---------|---------|
| `nix flake check` | Validate the flake on the current system | `nix flake check` |
| `nix flake check --all-systems` | Validate on all supported systems | `nix flake check --all-systems` |
| `nix flake update` | Update all inputs | `nix flake update` |
| `nix fmt` | Run `nixpkgs-fmt` on all Nix files | `nix fmt` |
| `nix build .#topology.<system>.config.output` | Build the topology output | `nix build .#topology.linux.config.output` |
| `nixos-rebuild switch --flake .#bpi` | Apply a NixOS host config | `sudo nixos-rebuild switch --flake .#bpi` |
| `darwin-rebuild switch --flake .#laplace` | Apply a Darwin host config | `sudo darwin-rebuild switch --flake .#laplace` |
| `nix repl -f flake:nixpkgs` | Interactive Nix REPL | `nix repl -f flake:nixpkgs` |

All commands are run from the repository root (`/workspace/nix`).

## Coding Style & Naming Conventions

- **Formatting** – Run `nix fmt` before committing. The repository uses
  `nixpkgs-fmt`.
- **Indentation** – 2‑space tabs are used throughout Nix files.
- **Module names** – Use lowercase with hyphens (e.g. `home‑manager`).
- **Package names** – Follow the pattern `<vendor>-<name>` (e.g. `codex-universal`).
- **Variables** – Prefer `snake_case` for Nix attributes.

## Testing Guidelines

The repository does not contain unit tests; instead, correctness is
ensured via **flake checks**. Treat `nix flake check` as your test
suite. When adding a new module or package, run:

```bash
nix flake check
nix flake check --all-systems
```

If a check fails, use `--show-trace` or `--verbose` to debug.

## Commit & Pull Request Guidelines

### Pre-commit

- Ensure pre-commit passes before committing.
- Pre-commit may automatically format files for you.
  Make sure to add these changes before trying to commit again.

### Commit messages

We follow the Conventional Commits format:

```
<type>[optional scope]: <short description>

optional body]
```

Typical types: `feat`, `fix`, `refactor`, `docs`, `style`, `test`, `chore`.

### Pull requests

- Provide a clear title and description.
- Reference the issue number (e.g. `Closes #42`).
- If the PR changes a host configuration, include a screenshot or
  diff of the relevant `flake.nix` section.
- Run `nix flake check` locally and include the output in the PR
  description.
- Ensure `nix fmt` passes.

## Security & Configuration Tips

- Secrets live in `secrets/` and are encrypted with Age. Never commit
  unencrypted secrets.

______________________________________________________________________

Happy hacking!

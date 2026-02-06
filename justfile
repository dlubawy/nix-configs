GIT_REPO := `git rev-parse --show-toplevel`
HOSTNAME := `hostname`
SYSTEM := `nix eval -f flake:nixpkgs 'system'`
USER := `whoami`

# Default recipe: check and build for current hostname
all: check (system HOSTNAME)

# Run checks for all systems
test: check-all

# Nix commands

# Update flake inputs
update:
    nix flake update

# Show system profile history
history:
    nix profile history --profile /nix/var/nix/profiles/system

# Show home-manager profile history
hm-history:
    nix profile history --profile ~/.local/state/nix/profiles/home-manager

# Start a Nix REPL
repl:
    nix repl -f flake:nixpkgs

# Clean old system profile generations (older than 7 days)
clean:
    sudo nix profile wipe-history --profile /nix/var/nix/profiles/system --older-than 7d

# Clean old home-manager profile generations
hm-clean:
    nix profile wipe-history --profile ~/.local/state/nix/profiles/home-manager

# Run garbage collection
gc:
    sudo nix-collect-garbage --delete-old

# Format Nix files
fmt:
    pre-commit run nixfmt-rfc-style --all

# Check flake for current system
check:
    #!/usr/bin/env bash
    if [ -n "$DEBUG" ]; then
        nix flake check --show-trace --verbose
    else
        nix flake check
    fi

# Check flake for all systems
check-all:
    #!/usr/bin/env bash
    if [ -n "$DEBUG" ]; then
        nix flake check --all-systems --show-trace --verbose
    else
        nix flake check --all-systems
    fi

# Build network topology
topology:
    nix build .#topology.{{SYSTEM}}.config.output

# Darwin systems

# Build and deploy laplace (MacBook M1)
laplace:
    #!/usr/bin/env bash
    if [ -n "$DEBUG" ]; then
        sudo -u laplace sudo chown -R laplace:staff {{GIT_REPO}} && \
        (sudo -Hu laplace sudo darwin-rebuild switch --flake {{GIT_REPO}}#laplace --show-trace --verbose || true) && \
        sudo -u laplace sudo chown -R {{USER}}:staff {{GIT_REPO}}
    else
        sudo -u laplace sudo chown -R laplace:staff {{GIT_REPO}} && \
        (sudo -Hu laplace sudo darwin-rebuild switch --flake {{GIT_REPO}}#laplace || true) && \
        sudo -u laplace sudo chown -R {{USER}}:staff {{GIT_REPO}}
    fi

# Build BPI image
bpi-image:
    #!/usr/bin/env bash
    if [ -n "$DEBUG" ]; then
        nix build {{GIT_REPO}}#images.bpi --show-trace --verbose
    else
        nix build {{GIT_REPO}}#images.bpi
    fi

# Build and deploy bpi (Banana Pi)
bpi:
    #!/usr/bin/env bash
    if [ -n "$DEBUG" ]; then
        sudo nixos-rebuild switch --flake {{GIT_REPO}}#bpi --show-trace --verbose
    else
        sudo nixos-rebuild switch --flake {{GIT_REPO}}#bpi
    fi

# Build and deploy lil-nas (GMKtec G9)
lil-nas:
    #!/usr/bin/env bash
    if [ -n "$DEBUG" ]; then
        sudo nixos-rebuild switch --flake {{GIT_REPO}}#lil-nas --show-trace --verbose
    else
        sudo nixos-rebuild switch --flake {{GIT_REPO}}#lil-nas
    fi

# Generic system builder (used by all recipe)
system hostname:
    just {{hostname}}

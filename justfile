GIT_REPO := `git rev-parse --show-toplevel`
HOSTNAME := `hostname`
HOST_PLATFORM := `nix eval -f flake:nixpkgs --raw 'pkgs.stdenv.hostPlatform.system'`
USER := `whoami`

# Default recipe: lint, test, and build for current hostname as system
default: lint test (build 'default' HOSTNAME)

# Build system with provided option
build option system:
    #!/usr/bin/env bash
    OPTION=""
    PLATFORM=""
    SYSTEM="{{ system }}"
    case "{{ HOST_PLATFORM }}" in
        *-darwin)
            PLATFORM=darwin
        ;;
        *-linux)
            PLATFORM=nixos
        ;;
        *)
            echo "Not a valid host platform" 1>&2
            exit 1
        ;;
    esac
    case "$SYSTEM" in
        companioncube|debian)
            PLATFORM=home-manager
            SYSTEM="{{ USER }}@$SYSTEM"
        ;;
        *@companioncube|*@debian)
            PLATFORM=home-manager
        ;;
        *)
            PLATFORM=$PLATFORM
        ;;
    esac
    case "{{ option }}" in
        default)
            if [[ "$PLATFORM" == "nixos" ]]; then
                OPTION=test
            else
                OPTION=switch
            fi
        ;;
        test)
            if [[ "$PLATFORM" != "nixos" ]]; then
                echo "Only 'switch' option supported by Darwin and Home Manager builders" 1>&2
                exit 1
            fi
            OPTION=test
        ;;
        switch)
            OPTION=switch
        ;;
        *)
            echo "Invalid option: {{ option }}" 1>&2
            exit 1
        ;;
    esac
    just "$PLATFORM" "$OPTION" "$SYSTEM"

# Run check for current system
test: check

# Run pre-commit against Nix files
lint:
    pre-commit run nixfmt-rfc-style --all
    pre-commit run flake-checker --all

################################################################
# Nix commands
################################################################

# Update flake inputs
update:
    nix flake update

# Show system profile history
history: hm-history
    nix profile history --profile /nix/var/nix/profiles/system

# Show home-manager profile history
hm-history:
    nix profile history --profile ~/.local/state/nix/profiles/home-manager

# Start a Nix REPL
repl:
    nix repl -f flake:nixpkgs

# Clean old system profile generations (older than 7 days)
clean: hm-clean
    #!/usr/bin/env bash
    case "{{ HOST_PLATFORM }}" in
        *-darwin)
            sudo -u {{ HOSTNAME }} sudo -H nix profile wipe-history --profile /nix/var/nix/profiles/system --older-than 7d
        ;;
        *)
            sudo nix profile wipe-history --profile /nix/var/nix/profiles/system --older-than 7d
        ;;
    esac

# Clean old home-manager profile generations
hm-clean:
    nix profile wipe-history --profile ~/.local/state/nix/profiles/home-manager

# Run garbage collection
gc:
    #!/usr/bin/env bash
    case "{{ HOST_PLATFORM }}" in
        *-darwin)
            sudo -u {{ HOSTNAME }} sudo -H nix-collect-garbage --delete-old
        ;;
        *)
            sudo nix-collect-garbage --delete-old
        ;;
    esac

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

################################################################
# Nix builds
################################################################

# Build network topology
topology:
    nix build {{ GIT_REPO }}#topology.{{ HOST_PLATFORM }}.config.output

# Build NixOS ISO installer
installer arch:
    nix build {{ GIT_REPO }}#images.nixos-iso-installer.{{ arch }}-linux

# Build and deploy Darwin system
darwin option system:
    #!/usr/bin/env bash
    if [ -n "$DEBUG" ]; then
        sudo -u {{ system }} sudo chown -R {{ system }}:staff {{ GIT_REPO }} && \
        (sudo -Hu {{ system }} sudo darwin-rebuild switch --flake {{ GIT_REPO }}#{{ system }} --show-trace --verbose || true) && \
        sudo -u {{ system }} sudo chown -R {{ USER }}:staff {{ GIT_REPO }}
    else
        sudo -u {{ system }} sudo chown -R {{ system }}:staff {{ GIT_REPO }} && \
        (sudo -Hu {{ system }} sudo darwin-rebuild switch --flake {{ GIT_REPO }}#{{ system }} || true) && \
        sudo -u {{ system }} sudo chown -R {{ USER }}:staff {{ GIT_REPO }}
    fi

# Build NixOS system images [bpi]
image system:
    #!/usr/bin/env bash
    if [ -n "$DEBUG" ]; then
        nix build {{ GIT_REPO }}#images.{{ system }} --show-trace --verbose
    else
        nix build {{ GIT_REPO }}#images.{{ system }}
    fi

# Build and deploy NixOS systems
nixos option system:
    #!/usr/bin/env bash
    if [[ "{{ HOSTNAME }}" == "{{ system }}" ]]; then
        CMD="sudo nixos-rebuild {{ option }} --flake {{ GIT_REPO }}#{{ system }}"
    else
        CMD="nixos-rebuild-ng {{ option }} --target-host {{ system }} --build-host {{ system }} --ask-sudo-password --use-substitutes --flake {{ GIT_REPO }}#{{ system }}"
    fi
    if [ -n "$DEBUG" ]; then
        $CMD --show-trace --verbose
    else
        $CMD
    fi

# Build and deploy home-manager homes
home-manager option home:
    #!/usr/bin/env bash
    if [ -n "$DEBUG" ]; then
        home-manager {{ option }} --flake '{{ GIT_REPO }}#{{ home }}' --show-trace --verbose
    else
        home-manager {{ option }} --flake '{{ GIT_REPO }}#{{ home }}'
    fi

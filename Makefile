GIT_REPO := $(shell git rev-parse --show-toplevel)
HOSTNAME := $(shell hostname)
SYSTEM := $(shell nix eval -f flake:nixpkgs 'system')
USER := $(shell whoami)

.PHONY: all test update history hm-history repl clean hm-clean gc fmt check laplace pi bpi

all: check $(HOSTNAME)

test: check-all

# Nix commands
update:
	nix flake update

history:
	nix profile history --profile /nix/var/nix/profiles/system

hm-history:
	nix profile history --profile ~/.local/state/nix/profiles/home-manager

repl:
	nix repl -f flake:nixpkgs

clean:
	sudo nix profile wipe-history --profile /nix/var/nix/profiles/system --older-than 7d

hm-clean:
	nix profile wipe-history --profile ~/.local/state/nix/profiles/home-manager

gc:
	sudo nix-collect-garbage --delete-old

fmt:
	nix fmt

check:
    ifdef DEBUG
		nix flake check --show-trace --verbose
    else
		nix flake check
    endif

check-all:
    ifdef DEBUG
		nix flake check --all-systems --show-trace --verbose
    else
		nix flake check --all-systems
    endif

topology:
	nix build .#topology.$(SYSTEM).config.output

# Darwin systems
laplace:
    ifdef DEBUG
		sudo -u laplace sudo chown -R laplace:staff $(GIT_REPO) && \
		(sudo -Hu laplace darwin-rebuild switch --flake $(GIT_REPO)\#laplace --show-trace --verbose || true) && \
		sudo -u laplace sudo chown -R $(USER):staff $(GIT_REPO)
    else
		sudo -u laplace sudo chown -R laplace:staff $(GIT_REPO) && \
		(sudo -Hu laplace darwin-rebuild switch --flake $(GIT_REPO)\#laplace || true) && \
		sudo -u laplace sudo chown -R $(USER):staff $(GIT_REPO)
    endif

bpi-image:
    ifdef DEBUG
		nix build $(GIT_REPO)\#images.bpi --show-trace --verbose
    else
		nix build $(GIT_REPO)\#images.bpi
    endif

bpi:
    ifdef DEBUG
		sudo nixos-rebuild switch --flake $(GIT_REPO)\#bpi --show-trace --verbose
    else
		sudo nixos-rebuild switch --flake $(GIT_REPO)\#bpi
    endif

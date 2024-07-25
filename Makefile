GIT_REPO := $(shell git rev-parse --show-toplevel)

.PHONY: update history repl clean gc fmt check laplace

# Nix commands
update:
	nix flake update

history:
	nix profile history --profile /nix/var/nix/profiles/system

repl:
	nix repl -f flake:nixpkgs

clean:
	sudo nix profile wipe-history --profile /nix/var/nix/profiles/system --older-than 7d

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

# Darwin systems
laplace:
    ifdef DEBUG
		darwin-rebuild switch --flake $(GIT_REPO)\#laplace --show-trace --verbose
    else
		darwin-rebuild switch --flake $(GIT_REPO)\#laplace
    endif

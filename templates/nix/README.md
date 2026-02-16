# Nix Development Environment Template

A clean Nix flake template for Nix-based projects with comprehensive pre-commit hooks and language server support.

## Overview

This template provides a minimal Nix development environment with:

- **Nix Language Server**: `nil` LSP for IDE integration
- **Code Formatting**: `nixfmt-rfc-style` for consistent style
- **Pre-commit Hooks**: Extensive quality checks
- **Flake Structure**: Standard flake template ready for customization

## Quick Start

Initialize a new Nix project:

```bash
nix flake init --template github:dlubawy/nix-configs/main#nix
```

Enter the development environment:

```bash
nix develop
```

## Project Structure

The template provides:

- `flake.nix` - Nix flake configuration with development shell
- `.gitignore` - Pre-configured for Nix projects

This is a foundation for building your own Nix projects, packages, or configurations.

## How It Works

### Development Shell

The template provides a basic development shell with:

- **nil**: Nix language server for IDE integration (autocomplete, go-to-definition, etc.)
- **nixfmt-rfc-style**: Official Nix formatter following RFC 166
- **Pre-commit hooks**: Automated quality checks

#### Environment Variables

The shell sets:

- `shell = "zsh"` - Preferred shell
- `NIL_PATH` - Path to the Nix language server binary

### Development Workflow

This template is a starting point. You'll likely want to add:

1. **Packages**: Define derivations to build software
1. **NixOS Modules**: Create reusable system configuration modules
1. **Home Manager Modules**: Define user-level configurations
1. **Applications**: Build and package applications
1. **Development Tools**: Add language-specific tooling

#### Example: Adding a Package

Extend `flake.nix` to build a package:

```nix
{
  # ... existing inputs ...

  outputs = { self, nixpkgs, ... }@inputs:
    let
      supportedSystems = [ /* ... */ ];
      forEachSupportedSystem = /* ... */;
    in
    {
      # Add packages output
      packages = forEachSupportedSystem ({ pkgs }: {
        default = pkgs.stdenv.mkDerivation {
          pname = "my-app";
          version = "1.0.0";
          src = builtins.path {
            path = ./.;
            name= "template";
          };

          buildPhase = ''
            # Your build commands
          '';

          installPhase = ''
            mkdir -p $out/bin
            cp my-app $out/bin/
          '';
        };
      });

      # ... existing checks and devShells ...
    };
}
```

#### Example: Adding a NixOS Module

```nix
{
  outputs = { self, nixpkgs, ... }@inputs:
    {
      nixosModules.default = { config, lib, pkgs, ... }: {
        options = {
          services.myservice.enable = lib.mkEnableOption "my service";
        };

        config = lib.mkIf config.services.myservice.enable {
          # Module implementation
        };
      };

      # ... existing outputs ...
    };
}
```

### Pre-commit Hooks

The template includes comprehensive quality checks that run automatically on commit:

- **Security**: `trufflehog` - Detect hardcoded secrets
- **Nix Quality**: `nixfmt-rfc-style` - Format Nix files using RFC 166 style
- **Documentation**: `mdformat` - Format Markdown files
- **Validation**:
  - `flake-checker` - Validate flake structure and best practices
  - `check-yaml` - Lint YAML files
- **Filesystem Safety**:
  - `check-case-conflicts` - Detect case sensitivity issues
  - `check-symlinks` - Validate symbolic links
- **Git Quality**:
  - `commitizen` - Validate commit messages (conventional commits)
  - `check-merge-conflicts` - Detect conflict markers
  - `forbid-new-submodules` - Prevent accidental submodule creation
  - `no-commit-to-branch` - Protect main branch from direct commits
  - `check-added-large-files` - Block large files (>5MB)

## Customization

### Adding Development Tools

Extend the `packages` list in the devShell:

```nix
packages = builtins.attrValues {
  inherit (pkgs)
  nil
  nixfmt-rfc-style
  # Add more tools:
  nix-tree        # Explore dependency trees
  nix-diff        # Diff Nix derivations
  nixpkgs-fmt     # Alternative formatter
  statix          # Linter for Nix
  deadnix         # Find dead Nix code
  alejandra       # Another Nix formatter
  ;
};
```

### Changing the Formatter

To use a different formatter, update both the pre-commit hook and package:

```nix
# In pre-commit hooks:
hooks = {
  alejandra = {  # Instead of nixfmt-rfc-style
    enable = true;
    name = "🔍 Code Quality · ❄️ Nix · Format";
  };
  # ...
};

# In packages:
packages = builtins.attrValues {
  inherit (pkgs)
  nil
  alejandra  # Instead of nixfmt-rfc-style
  ;
};
```

### Adding More Pre-commit Hooks

Extend the hooks in `checks.pre-commit-check.hooks`:

```nix
hooks = {
  # ... existing hooks ...

  statix = {
    enable = true;
    name = "🔍 Code Quality · ❄️ Nix · Lint";
  };

  deadnix = {
    enable = true;
    name = "🔍 Code Quality · ❄️ Nix · Dead code";
  };
};
```

### Using a Different Shell

Change the shell environment variable:

```nix
env = {
  shell = "bash";  # or "fish", "zsh", etc.
  NIL_PATH = "${pkgs.nil}/bin/nil";
};
```

### Modifying Pre-commit Hook Order

The hooks use `after` to define execution order. Adjust as needed:

```nix
my-hook = {
  enable = true;
  after = [ "other-hook" ];  # Run after other-hook
};
```

## Platform Support

This template supports:

- `x86_64-linux`
- `aarch64-linux`
- `x86_64-darwin` (macOS Intel)
- `aarch64-darwin` (macOS Apple Silicon)

## Common Use Cases

### Building a CLI Tool

```nix
packages = forEachSupportedSystem ({ pkgs }: {
  my-cli = pkgs.writeShellScriptBin "my-cli" ''
    #!/usr/bin/env bash
    echo "Hello from my CLI!"
  '';
});
```

### Creating a Development Environment for Another Language

```nix
devShells = forEachSupportedSystem ({ pkgs }: {
  default = pkgs.mkShell {
    buildInputs = builtins.attrValues {
      inherit (pkgs)
      # Add your language tooling
      nodejs
      python3
      go
      ;
    };
    packages = builtins.attrValues {
      inherit (pkgs)
      nil
      nixfmt-rfc-style
      ;
    };
  };
});
```

### Building a Docker Image

```nix
packages = forEachSupportedSystem ({ pkgs }: {
  docker-image = pkgs.dockerTools.buildImage {
    name = "my-app";
    tag = "latest";
    contents = [ self.packages.${pkgs.system}.my-app ];
    config = {
      Cmd = [ "/bin/my-app" ];
    };
  };
});
```

### Exporting Multiple Packages

```nix
packages = forEachSupportedSystem ({ pkgs }: {
  app1 = pkgs.callPackage ./app1 {};
  app2 = pkgs.callPackage ./app2 {};
  default = self.packages.${pkgs.system}.app1;
});
```

## Troubleshooting

### `nil` not working in IDE

1. Ensure you're in the development shell
1. Check that `NIL_PATH` is set: `echo $NIL_PATH`
1. Configure your editor to use `$NIL_PATH`
1. Restart your editor from within the Nix shell

### Formatting issues

The template uses `nixfmt-rfc-style` which follows [RFC 166](https://github.com/NixOS/rfcs/pull/166). If you prefer a different style:

1. Change the formatter package
1. Update the pre-commit hook
1. Run `nix fmt` or your chosen formatter

### Flake evaluation errors

```bash
# Check flake structure
nix flake check

# Show flake metadata
nix flake metadata

# Update flake inputs
nix flake update
```

### Pre-commit hooks fail

Run hooks manually to see detailed error messages:

```bash
git commit  # hooks run automatically
# OR
pre-commit run --all-files  # run all hooks manually
```

### Build fails on different platforms

Ensure you're using `forEachSupportedSystem` and only include platforms you support:

```nix
supportedSystems = [
  "x86_64-linux"
  "aarch64-linux"
  # Add/remove as needed
];
```

## References

- [Nix Manual](https://nixos.org/manual/nix/stable/)
- [Nix Pills](https://nixos.org/guides/nix-pills/)
- [nixpkgs Manual](https://nixos.org/manual/nixpkgs/stable/)
- [Nix Flakes](https://nixos.wiki/wiki/Flakes)
- [RFC 166 - Nix Formatting](https://github.com/NixOS/rfcs/pull/166)
- [nil Language Server](https://github.com/oxalica/nil)
- [Zero to Nix](https://zero-to-nix.com/)

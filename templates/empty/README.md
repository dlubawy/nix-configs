# Empty Development Environment Template

A minimal Nix flake template providing just the essential development tools and pre-commit hooks. Perfect as a starting point for any project or when you need a lightweight environment.

## Overview

This template provides a bare-bones development environment with:

- **Nix Tooling**: Language server and formatter
- **Pre-commit Hooks**: Comprehensive quality checks
- **No Language-Specific Tools**: Bring your own tooling
- **Clean Foundation**: Minimal structure ready for customization

## Quick Start

Initialize a new project:

```bash
nix flake init --template github:dlubawy/nix-configs/main#empty
```

Enter the development environment:

```bash
nix develop
```

## Project Structure

The template provides:

- `flake.nix` - Minimal Nix flake configuration
- `.envrc` - direnv configuration for automatic environment activation
- `flake.lock` - Locked dependency versions

This is the most minimal starting point for any Nix-based project.

## How It Works

### Development Shell

The development shell includes only:

- **nil**: Nix language server for IDE integration
- **nixfmt-rfc-style**: Official Nix formatter
- **Pre-commit hooks**: Automated quality checks

No language-specific tools are included. Add what you need.

### Use Cases

This template is ideal for:

1. **Quick Experiments**: Need a clean environment fast
1. **Custom Environments**: Build your own from scratch
1. **Non-Programming Projects**: Documentation, infrastructure, etc.
1. **Learning Nix**: Minimal template to understand flakes
1. **Mixed-Language Projects**: Add multiple language toolchains

## Pre-commit Hooks

Despite being "empty," the template includes comprehensive quality checks:

- **Security**: `trufflehog` - Detect hardcoded secrets
- **Nix Quality**: `nixfmt-rfc-style` - Format Nix files
- **Documentation**: `mdformat` - Format Markdown files
- **Validation**:
  - `flake-checker` - Validate flake structure
  - `check-yaml` - Lint YAML files
- **Filesystem Safety**:
  - `check-case-conflicts` - Detect case sensitivity issues
  - `check-symlinks` - Validate symbolic links
- **Git Quality**:
  - `commitizen` - Validate commit messages
  - `check-merge-conflicts` - Detect conflict markers
  - `forbid-new-submodules` - Prevent submodule creation
  - `no-commit-to-branch` - Protect main branch
  - `check-added-large-files` - Block large files (>5MB)

These hooks ensure basic quality standards regardless of your project type.

## Customization

### Adding Development Tools

The most common customization is adding tools to the development shell:

```nix
devShells = forEachSupportedSystem ({ pkgs }: {
  default = pkgs.mkShell {
    inherit (self.checks.${pkgs.stdenv.hostPlatform.system}.pre-commit-check) shellHook;
    buildInputs = self.checks.${pkgs.stdenv.hostPlatform.system}.pre-commit-check.enabledPackages;
    packages = builtins.attrValues {
      inherit (pkgs)
      nil
      nixfmt-rfc-style

      # Add your tools here:
      # Programming languages
      python3
      nodejs
      go
      rustc
      cargo

      # Build tools
      cmake
      gnumake

      # Utilities
      jq
      yq
      curl
      wget

      # Cloud tools
      awscli2
      google-cloud-sdk
      terraform
      ;
    };
    env = {
      shell = "zsh";
      NIL_PATH = "${pkgs.nil}/bin/nil";
      # Add your environment variables
    };
  };
});
```

### Creating a Multi-Language Environment

Perfect template for projects using multiple languages:

```nix
packages = builtins.attrValues {
  inherit (pkgs)
  # Nix tooling
  nil
  nixfmt-rfc-style

  # Python
  python3
  python3Packages.pip
  python3Packages.virtualenv

  # Node.js
  nodejs_20
  nodePackages.npm

  # Go
  go
  gopls

  # Rust
  rustc
  cargo
  rust-analyzer

  # Shell scripting
  shellcheck
  shfmt
  ;
};
```

### Adding Language-Specific Pre-commit Hooks

Extend the hooks based on your project:

```nix
hooks = {
  # Existing hooks...

  # Python
  black = {
    enable = true;
    name = "🔍 Code Quality · 🐍 Python · Format";
  };

  # JavaScript/TypeScript
  prettier = {
    enable = true;
    name = "🔍 Code Quality · JS/TS · Format";
  };

  # Shell scripts
  shellcheck = {
    enable = true;
    name = "🔍 Code Quality · Shell · Lint";
  };
};
```

### Removing Unnecessary Hooks

If some hooks don't apply to your project:

```nix
hooks = {
  trufflehog = {
    enable = true;
    name = "🔒 Security · Detect hardcoded secrets";
  };
  nixfmt-rfc-style = {
    enable = true;
    name = "🔍 Code Quality · ❄️ Nix · Format";
  };
  # Remove hooks by not including them
  # Or explicitly disable:
  mdformat = {
    enable = false;  # Disable markdown formatting
  };
};
```

### Adding Build Outputs

Transform this into a builder for your project:

```nix
outputs = { self, nixpkgs, ... }@inputs:
  let
    # ... existing let bindings ...
  in
  {
    # Add packages
    packages = forEachSupportedSystem ({ pkgs }: {
      default = pkgs.stdenv.mkDerivation {
        pname = "my-project";
        version = "1.0.0";
        src = ./.;

        buildPhase = ''
          # Your build commands
        '';

        installPhase = ''
          mkdir -p $out
          # Copy outputs
        '';
      };
    });

    # Existing checks and devShells...
  };
```

## Platform Support

This template supports:

- `x86_64-linux`
- `aarch64-linux`
- `x86_64-darwin` (macOS Intel)
- `aarch64-darwin` (macOS Apple Silicon)

## Common Patterns

### Quick Script Environment

Use for one-off scripts:

```nix
packages = builtins.attrValues {
  inherit (pkgs)
  nil
  nixfmt-rfc-style
  bash
  python3
  jq
  curl
  ;
};
```

### Documentation Project

For documentation-only projects:

```nix
packages = builtins.attrValues {
  inherit (pkgs)
  nil
  nixfmt-rfc-style
  # Documentation tools
  mdbook
  hugo
  pandoc
  graphviz
  plantuml
  ;
};
```

### Infrastructure as Code

For managing infrastructure:

```nix
packages = builtins.attrValues {
  inherit (pkgs)
  nil
  nixfmt-rfc-style
  # IaC tools
  terraform
  terragrunt
  ansible
  kubectl
  helm
  ;
};
```

### Data Analysis

For data science projects:

```nix
packages = builtins.attrValues {
  inherit (pkgs)
  nil
  nixfmt-rfc-style
  # Data tools
  python3
  python3Packages.pandas
  python3Packages.jupyter
  python3Packages.matplotlib
  R
  rstudio
  ;
};
```

## Migrating to Specialized Templates

As your project grows, you might want more structure:

```bash
# Switch to Python template
nix flake init --template github:dlubawy/nix-configs/main#python

# Or Go template
nix flake init --template github:dlubawy/nix-configs/main#go

# Or Rust template
nix flake init --template github:dlubawy/nix-configs/main#rust
```

**Note**: This will overwrite your `flake.nix`. Save your customizations first.

## Troubleshooting

### Nothing to do in the shell

That's expected! This template provides only Nix tools. Add packages specific to your project needs.

### Pre-commit hooks running unnecessary checks

Disable hooks you don't need in the `checks.pre-commit-check.hooks` section.

### Missing tools

Add them to the `packages` list in `devShells.default`.

### Flake check fails

```bash
# Validate flake structure
nix flake check

# Show detailed errors
nix flake check --show-trace
```

### Pre-commit hooks fail

Run hooks manually to see detailed error messages:

```bash
git commit  # hooks run automatically
# OR
pre-commit run --all-files  # run all hooks manually
```

## When to Use This Template

**Use the empty template when:**

- You want complete control over the environment
- You're building a multi-language project
- You need minimal overhead
- You're learning Nix and want to understand the basics
- Your project doesn't fit other templates

**Use a specialized template when:**

- You're working primarily in one language (Python, Rust, Go, etc.)
- You want language-specific best practices
- You need a fully configured environment quickly

## References

- [Nix Manual](https://nixos.org/manual/nix/stable/)
- [Nix Flakes](https://nixos.wiki/wiki/Flakes)
- [nixpkgs Manual](https://nixos.org/manual/nixpkgs/stable/)
- [Search nixpkgs Packages](https://search.nixos.org/packages)
- [Nix Pills](https://nixos.org/guides/nix-pills/)
- [Zero to Nix](https://zero-to-nix.com/)

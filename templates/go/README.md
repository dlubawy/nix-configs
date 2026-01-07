# Go Development Environment Template

A complete Nix flake template for Go development with integrated tooling, pre-commit hooks, and package building.

## Overview

This template provides a complete Go development environment with:

- **Go Toolchain**: Latest Go compiler and tools
- **Language Server**: gopls for IDE integration
- **Code Quality**: gofmt for formatting
- **Pre-commit Hooks**: Extensive quality checks
- **Package Building**: Nix-based Go module building

## Quick Start

Initialize a new Go project:

```bash
nix flake init --template github:dlubawy/nix-configs/main#go
```

Enter the development environment:

```bash
nix develop
```

## Project Structure

The template creates:

- `flake.nix` - Nix flake configuration with Go toolchain and build setup
- `go.mod` - Go module definition
- `main.go` - Sample "Hello World" application
- `.envrc` - direnv configuration for automatic environment activation
- `.gitignore` - Pre-configured for Go projects

## How It Works

### Go Module Management

The template provides a basic Go module structure:

```go
// go.mod
module template

go 1.23.7
```

#### Adding Dependencies

Add imports to your Go code and run:

```bash
go get ./...
go mod tidy
```

Update the `vendorHash` in `flake.nix` after adding dependencies (see [Building Packages](#building-packages) below).

### Development Workflow

#### Building and Running

```bash
# Run the application
go run .

# Build binary
go build -o myapp

# Run tests
go test ./...

# Run tests with coverage
go test -cover ./...
```

#### Code Formatting

```bash
# Format all Go files
go fmt ./...

# Or use gofmt directly
gofmt -w .
```

#### Using gopls (Language Server)

The template includes `gopls` for IDE integration. Most editors will automatically detect and use it when in the Nix shell.

For VS Code with Go extension:

1. Enter the Nix shell (`nix develop`)
1. Open VS Code from within the shell
1. The Go extension will use the gopls from the Nix environment

### Building Packages

The template includes a Nix package definition using `buildGoModule`:

```nix
packages = forEachSupportedSystem ({ pkgs }: {
  default = pkgs.buildGoModule {
    name = "template";
    src = ./.;
    vendorHash = null;  # Update this when adding dependencies
  };
});
```

#### Building with Nix

```bash
# Build the package
nix build

# Run from the built package
./result/bin/template

# Or run directly
nix run
```

#### Updating vendorHash

When you add Go dependencies:

1. Add the dependency to your code and run `go mod tidy`
1. Try building: `nix build`
1. If it fails with a hash mismatch, update `vendorHash` in `flake.nix`:

```nix
# Replace null with the hash from the error message
vendorHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";

# Or use lib.fakeHash for the correct hash in the error:
vendorHash = lib.fakeHash;  # Build will fail with correct hash
```

1. Update the hash with the one from the error message
1. Build again: `nix build`

Alternatively, set `vendorHash = null` if you're not vendoring dependencies.

### Pre-commit Hooks

The template includes comprehensive quality checks that run automatically on commit:

- **Security**: `trufflehog` - Detect hardcoded secrets
- **Go Quality**: `gofmt` - Format Go code
- **Nix Quality**: `nixfmt-rfc-style` - Format Nix files
- **Documentation**: `mdformat` - Format Markdown files
- **Validation**:
  - `flake-checker` - Validate flake structure
  - `check-yaml` - Lint YAML files
- **Git Quality**:
  - `commitizen` - Validate commit messages
  - `check-merge-conflicts` - Detect conflict markers
  - `check-added-large-files` - Block large files (>5MB)
  - `no-commit-to-branch` - Protect main branch

## Customization

### Changing the Package Name

1. Update the `name` field in `flake.nix` under `packages.default`
1. Update `module` name in `go.mod`
1. Update import paths in your Go code

### Changing Go Version

The Go version is determined by the nixpkgs version. To use a specific Go version:

```nix
nativeBuildInputs = with pkgs; [
  go_1_22  # Use Go 1.22
  # or go_1_21, go (latest), etc.
  gopls
];
```

### Adding Development Tools

Add more tools to the `packages` list in the devShell:

```nix
packages = with pkgs; [
  nil
  nixfmt-rfc-style
  # Add more tools:
  golangci-lint  # Linter aggregator
  delve          # Debugger
  gotools        # Additional Go tools
];
```

### Build Flags

Customize the build with `buildGoModule` options:

```nix
default = pkgs.buildGoModule {
  name = "template";
  src = ./.;
  vendorHash = null;
  
  # Add build flags
  ldflags = [
    "-s"  # Strip debug info
    "-w"  # Strip DWARF symbols
    "-X main.version=${version}"  # Set variables
  ];
  
  # Build tags
  tags = [ "netgo" ];
  
  # Disable CGO
  CGO_ENABLED = 0;
};
```

### Modifying Pre-commit Hooks

Edit the `checks.pre-commit-check.hooks` section in `flake.nix` to enable, disable, or configure hooks.

## Platform Support

This template supports:

- `x86_64-linux`
- `aarch64-linux`
- `x86_64-darwin` (macOS Intel)
- `aarch64-darwin` (macOS Apple Silicon)

## Common Tasks

### Testing

```bash
# Run all tests
go test ./...

# Run tests with verbose output
go test -v ./...

# Run specific test
go test -run TestFunctionName ./...

# Run benchmarks
go test -bench=. ./...

# Generate coverage report
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out
```

### Vendoring Dependencies

To vendor dependencies instead of using `vendorHash`:

```bash
# Vendor dependencies
go mod vendor

# In flake.nix, set:
vendorHash = null;

# And add to buildGoModule:
proxyVendor = false;
```

### Cross-compilation

Build for different platforms:

```bash
# Linux AMD64
GOOS=linux GOARCH=amd64 go build -o myapp-linux-amd64

# macOS ARM64
GOOS=darwin GOARCH=arm64 go build -o myapp-darwin-arm64

# Windows AMD64
GOOS=windows GOARCH=amd64 go build -o myapp-windows-amd64.exe
```

For Nix builds, use cross-compilation features:

```nix
# In flake.nix, create additional packages for different platforms
packages.x86_64-linux.static = pkgs.pkgsStatic.buildGoModule {
  # ... static build configuration
};
```

## Troubleshooting

### `go` command not found

Ensure you're in the development shell:

```bash
nix develop
# or with direnv:
direnv allow
```

### Build fails with hash mismatch

Update `vendorHash` in `flake.nix` with the hash from the error message. See [Updating vendorHash](#updating-vendorhash).

### gopls not working in IDE

1. Ensure you started your editor from within the Nix shell
1. Check that gopls is in PATH: `which gopls`
1. Restart your editor

### Module import errors

After changing the module name in `go.mod`, update all import paths:

```bash
# If you renamed from 'template' to 'myapp'
find . -name '*.go' -exec sed -i 's|template/|myapp/|g' {} +
```

### Pre-commit hooks fail

Run hooks manually to see detailed error messages:

```bash
git commit  # hooks run automatically
# OR
pre-commit run --all-files  # run all hooks manually
```

## References

- [Go Documentation](https://go.dev/doc/)
- [Effective Go](https://go.dev/doc/effective_go)
- [Go Modules Reference](https://go.dev/ref/mod)
- [gopls Documentation](https://pkg.go.dev/golang.org/x/tools/gopls)
- [Nix buildGoModule](https://nixos.org/manual/nixpkgs/stable/#sec-language-go)

# Rust Development Environment Template

A comprehensive Nix flake template for Rust development with integrated tooling and pre-commit hooks.

## Overview

This template provides a complete Rust development environment with:

- **Rust Toolchain**: Complete Rust development toolchain (cargo, rustc, rust-src)
- **Code Quality**: rustfmt and clippy pre-configured
- **Pre-commit Hooks**: Extensive quality checks and formatters
- **LSP Support**: Rust analyzer and Nix language server
- **Cross-platform**: Supports Linux and macOS (Intel & Apple Silicon)

## Quick Start

Initialize a new Rust project:

```bash
nix flake init --template github:dlubawy/nix-configs/main#rust
```

Enter the development environment:

```bash
nix develop
```

## Project Structure

The template provides:

- `flake.nix` - Nix flake configuration with Rust toolchain
- `.envrc` - direnv configuration for automatic environment activation
- `.gitignore` - Pre-configured for Rust projects

You'll need to initialize a Rust project with:

```bash
cargo init
```

## How It Works

### Rust Toolchain

The development shell provides a complete Rust environment from nixpkgs:

- `cargo` - Rust package manager and build tool
- `rustc` - Rust compiler
- `rustLibSrc` - Rust standard library source (for IDE features)
- `clippy` - Rust linter for catching common mistakes
- `rustfmt` - Code formatter for consistent style

The `RUST_SRC_PATH` environment variable is automatically set to enable IDE features like "go to definition" for standard library code.

### Development Workflow

#### Creating a New Project

After initializing the template:

```bash
# Create a binary project
cargo init

# Or create a library
cargo init --lib
```

#### Building and Running

```bash
# Build the project
cargo build

# Run the project
cargo run

# Run tests
cargo test

# Check code without building
cargo check
```

#### Using Clippy

```bash
# Run clippy linter
cargo clippy

# Run clippy with warnings as errors
cargo clippy -- -D warnings
```

#### Formatting Code

```bash
# Format all Rust code
cargo fmt

# Check formatting without changing files
cargo fmt -- --check
```

### Pre-commit Hooks

The template includes comprehensive quality checks that run automatically on commit:

- **Security**: `trufflehog` - Detect hardcoded secrets
- **Rust Quality**:
  - `rustfmt` - Format Rust code
  - `clippy` - Lint Rust code for common mistakes
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

### Using Nightly Rust

To use Rust nightly instead of stable, modify `flake.nix`:

```nix
# Replace the packages section in devShells
packages = with pkgs; [
  (with rustPlatform; [
    cargo
    rustc
    rustLibSrc
    nil
    nixfmt-rfc-style
  ])
  clippy
  rustfmt
];

# With:
packages = [
  pkgs.rustup
  pkgs.nil
  pkgs.nixfmt-rfc-style
];

# Then in the shell, install nightly:
# rustup default nightly
```

### Adding Additional Tools

Add more development tools to the `packages` list in `flake.nix`:

```nix
packages = with pkgs; [
  # ... existing packages ...
  cargo-watch    # Auto-rebuild on file changes
  cargo-edit     # Add/remove dependencies from command line
  cargo-audit    # Check dependencies for security vulnerabilities
  rust-analyzer  # Language server for IDE integration
];
```

### Modifying Pre-commit Hooks

Edit the `checks.pre-commit-check.hooks` section in `flake.nix` to enable, disable, or configure hooks.

### IDE Integration

The template sets `RUST_SRC_PATH` for IDE features. For full IDE support, consider adding `rust-analyzer`:

```nix
packages = with pkgs; [
  # ... existing packages ...
  rust-analyzer
];
```

## Platform Support

This template supports:

- `x86_64-linux`
- `aarch64-linux`
- `x86_64-darwin` (macOS Intel)
- `aarch64-darwin` (macOS Apple Silicon)

## Common Tasks

### Managing Dependencies

Edit `Cargo.toml` to add dependencies:

```toml
[dependencies]
serde = { version = "1.0", features = ["derive"] }
tokio = { version = "1.0", features = ["full"] }
```

Or use `cargo add` (if `cargo-edit` is installed):

```bash
cargo add serde --features derive
```

### Running in Release Mode

```bash
# Build with optimizations
cargo build --release

# Run optimized binary
cargo run --release

# Binary is in target/release/
./target/release/your-binary-name
```

### Cross-compilation

For cross-compilation, you'll need to add the appropriate Rust targets and configure the toolchain. This template uses the standard Rust toolchain from nixpkgs, which supports the native platform.

## Troubleshooting

### Cargo fails to find the Rust compiler

Make sure you're in the development shell:

```bash
nix develop
# or if using direnv:
direnv allow
```

### IDE doesn't have code completion

1. Ensure `RUST_SRC_PATH` is set (check with `echo $RUST_SRC_PATH`)
1. Install `rust-analyzer` in your IDE
1. Restart your IDE after entering the Nix shell

### Pre-commit hooks fail

Run hooks manually to see detailed error messages:

```bash
git commit  # hooks run automatically
# OR
pre-commit run --all-files  # run all hooks manually
```

### Clippy warnings block commits

This is intentional! Fix the clippy warnings or temporarily skip hooks:

```bash
git commit --no-verify  # Skip pre-commit hooks (use sparingly)
```

## References

- [The Rust Programming Language Book](https://doc.rust-lang.org/book/)
- [Rust by Example](https://doc.rust-lang.org/rust-by-example/)
- [Cargo Book](https://doc.rust-lang.org/cargo/)
- [Clippy Documentation](https://doc.rust-lang.org/clippy/)
- [rustfmt Configuration](https://rust-lang.github.io/rustfmt/)

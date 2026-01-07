# Python Development Environment Template

A fully-featured Nix flake template for Python development using modern tooling: `uv`, `pyproject.nix`, and comprehensive pre-commit hooks.

## Overview

This template provides a complete Python development environment with:

- **Dependency Management**: `uv` for fast, reliable Python package management
- **Build System**: `pyproject.nix` for reproducible builds with Nix
- **Virtual Environment**: Automatically managed Python virtual environment
- **Pre-commit Hooks**: Extensive quality checks and formatters
- **Editable Installs**: Development shell with editable package support

## Quick Start

Initialize a new Python project:

```bash
nix flake init --template github:dlubawy/nix-configs/main#python
```

Enter the development environment:

```bash
nix develop
```

## Project Structure

The template creates these key files:

- `flake.nix` - Nix flake configuration defining inputs, outputs, packages, and dev shells
- `pyproject.toml` - Python project metadata and build configuration
- `uv.lock` - Locked dependency versions managed by `uv`
- `src/template/` - Python package source code
- `.envrc` - direnv configuration for automatic environment activation

## How It Works

### Dependency Management: `flake.nix` ↔ `pyproject.toml` ↔ `uv`

The template integrates three layers of dependency management:

#### 1. `pyproject.toml` - Project Definition

Define your Python project metadata and dependencies:

```toml
[project]
name = "template"
version = "0.1.0"
requires-python = ">=3.10"
dependencies = [
    # Add your runtime dependencies here
]

[project.optional-dependencies]
dev = [
    # Add development dependencies here
]
```

#### 2. `uv.lock` - Locked Dependencies

Run `uv lock` to generate a lock file with pinned dependency versions. The lock file ensures reproducible builds across environments.

```bash
# Add a new dependency
uv add requests

# Update dependencies
uv lock --upgrade
```

#### 3. `flake.nix` - Nix Integration

The flake uses `uv2nix` to convert `uv.lock` into Nix derivations:

- Loads workspace from current directory
- Creates Python package overlay from `uv.lock`
- Builds virtual environment with all dependencies
- Provides editable installs for development

### Development Workflow

#### Adding Dependencies

1. Edit `pyproject.toml` to add dependencies OR use `uv add <package>`
2. Run `uv lock` to update the lock file
3. Re-enter the dev shell with `nix develop` or `direnv allow`

The dev shell automatically provides the updated virtual environment.

#### Development Shell Features

The `nix develop` shell provides:

- **Python Virtual Environment**: Pre-built with all dependencies
- **Editable Package**: Your package is installed in editable mode via `REPO_ROOT` environment variable
- **UV Integration**: `uv` is configured to use the Nix-managed Python interpreter
- **Pre-commit Hooks**: Automatically installed and configured
- **LSP Support**: `nil` language server for Nix files

#### Environment Variables

The dev shell sets these environment variables:

- `UV_NO_SYNC=1` - Prevents `uv` from creating its own venv
- `UV_PYTHON` - Points to the Nix-managed Python interpreter
- `UV_PYTHON_DOWNLOADS=never` - Prevents `uv` from downloading Python versions
- `REPO_ROOT` - Repository root for editable installs
- `NIL_PATH` - Path to Nix language server

### Building and Running

#### Run the Package

```bash
# Using nix run
nix run

# Or directly from dev shell
template
```

#### Build a Package

```bash
# Build the package
nix build

# Result is in ./result/bin/
./result/bin/template
```

The package output includes a complete virtual environment with all dependencies.

### Pre-commit Hooks

The template includes comprehensive quality checks that run automatically on commit:

- **Security**: `trufflehog` - Detect hardcoded secrets
- **Python Quality**:
  - `ruff` - Fast linting with auto-fixes
  - `ruff-format` - Code formatting
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

### Modifying the Package Name

1. Update `name` in `pyproject.toml`
2. Rename `src/template/` directory to match your package name
3. Update `project.scripts` in `pyproject.toml` to point to your module
4. Update references in `flake.nix` (search for "template")

### Adding Build Fixups

If a dependency needs build-time patches, add them in `pyprojectOverrides`:

```nix
pyprojectOverrides = final: prev: {
  my-package = prev.my-package.overrideAttrs (old: {
    buildInputs = old.buildInputs ++ [ final.some-native-dep ];
  });
};
```

### Changing Python Version

Update the `python` version in `flake.nix`:

```nix
python = pkgs.python311;  # or python312, python313, etc.
```

### Modifying Pre-commit Hooks

Edit the `checks.pre-commit-check.hooks` section in `flake.nix` to enable, disable, or configure hooks.

## Platform Support

This template supports:

- `x86_64-linux`
- `aarch64-linux`
- `x86_64-darwin` (macOS Intel)
- `aarch64-darwin` (macOS Apple Silicon)

## Advanced Topics

### Editable Installs

In the dev shell, your package is installed in editable mode. Changes to Python source files are immediately reflected without reinstalling. This is achieved through:

1. `workspace.mkEditablePyprojectOverlay` creates an overlay with editable packages
2. The overlay uses `$REPO_ROOT` environment variable to find sources
3. A filtered source tree minimizes rebuilds on unrelated changes

### Virtual Environment Details

The template creates two virtual environments:

1. **Package**: `mkVirtualEnv "template-env" workspace.deps.default` - Production dependencies only
2. **Dev Shell**: `mkVirtualEnv "template-dev-env" workspace.deps.all` - All dependencies including optional ones

### Build System

The template uses `hatchling` as the build backend (defined in `pyproject.toml`). For editable installs, the `editables` package is automatically added as a build dependency per PEP-660.

## Troubleshooting

### `uv` tries to create its own virtual environment

The dev shell sets `UV_NO_SYNC=1` to prevent this. If you're using `uv` outside the dev shell, it will create its own venv.

### Changes to Python files aren't reflected

Make sure you're in the dev shell where editable mode is enabled. The package built with `nix build` is not editable.

### Pre-commit hooks fail

Run hooks manually to see detailed error messages:

```bash
git commit  # hooks run automatically
# OR
pre-commit run --all-files  # run all hooks manually
```

### Dependencies not found

After modifying `pyproject.toml`:

1. Run `uv lock` to update the lock file
2. Re-enter the dev shell with `direnv allow` or `nix develop`

## References

- [pyproject.nix Documentation](https://pyproject-nix.github.io/pyproject.nix/)
- [uv2nix](https://github.com/pyproject-nix/uv2nix)
- [uv Documentation](https://docs.astral.sh/uv/)
- [PEP 660 - Editable Installs](https://peps.python.org/pep-0660/)

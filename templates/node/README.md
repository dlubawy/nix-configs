# Node.js Development Environment Template

A modern Nix flake template for Node.js development with pnpm, Vite integration, pre-commit hooks, and deployment packaging.

## Overview

This template provides a complete Node.js-based web development environment with:

- **Node.js Runtime**: Modern JavaScript/TypeScript runtime
- **pnpm**: Fast, disk-efficient package manager (pinned major version for reproducible builds)
- **Vite Integration**: Fast build tooling via `create-vite` script
- **Code Quality**: oxfmt and oxlint built-in
- **Pre-commit Hooks**: Extensive quality checks
- **Package Building**: Complete deployable package using the nixpkgs pnpm packaging helpers

The template ships with a minimal Vite + Svelte (TypeScript) example project, so `nix build .`, `nix run .`, `nix shell .`, and `nix develop .` all work out of the box.

## Quick Start

Initialize a new Node.js project:

```bash
nix flake init --template github:dlubawy/nix-configs/main#node
```

Enter the development environment:

```bash
nix develop
```

Create a Vite project in a fresh directory:

```bash
create-vite
```

## Project Structure

The template provides:

- `flake.nix` - Nix flake configuration with pnpm packaging and a Vite example app
- `.gitignore` - Pre-configured for Node projects
- `package.json` / `pnpm-lock.yaml` - Minimal Vite + Svelte (TypeScript) project
- `index.html`, `src/`, `public/`, `vite.config.ts`, `tsconfig.json` - The example app

## How It Works

### pnpm

The template uses [pnpm](https://pnpm.io), a fast and disk-efficient Node.js package manager. The major version is pinned in `flake.nix` (currently `pkgs.pnpm_11`) for reproducible builds, matching the lockfile version used by the project.

### Vite Integration

The template includes a helper script `create-vite` that runs:

```bash
pnpm create vite .
```

This initializes a Vite project in the current directory. Choose from various frameworks:

- Vanilla JavaScript/TypeScript
- React
- Vue
- Svelte
- Preact
- Lit
- And more...

### Development Workflow

#### Running the Example Project

```bash
# Install dependencies (usually already done by the dev shell)
pnpm install

# Start development server with HMR
pnpm dev

# Build for production
pnpm build

# Preview production build locally
pnpm preview
```

### Building Packages

The template includes a Nix package built with the [nixpkgs pnpm packaging helpers](https://nixos.org/manual/nixpkgs/stable/#javascript-pnpm):

1. `fetchPnpmDeps` pre-fetches the pnpm dependency store from `pnpm-lock.yaml` as a fixed-output derivation
1. `pnpmConfigHook` installs the pre-fetched dependencies during the build
1. Vite builds the production bundle
1. A wrapper script serves the built application with `vite preview`

#### Building with Nix

```bash
# Build the package
nix build .

# Run the packaged application (starts preview server on port 4173)
nix run .

# The port and host can be overridden
PORT=8080 nix run .
```

The built package includes:

- Compiled Vite application (`dist/`)
- Node modules (frozen in the store)
- Wrapper script for serving the built application

### Pre-commit Hooks

The template includes comprehensive quality checks that run automatically on commit:

- **Security**: `trufflehog` - Detect hardcoded secrets
- **Node Quality**:
  - `oxfmt` - Format JavaScript/TypeScript code
  - `oxlint` - Lint code for common issues
- **Nix Quality**: `nixfmt` - Format Nix files
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

Update the `pname` field in `flake.nix`:

```nix
pname = "my-app";  # Change this
```

The wrapper script in `installPhase` uses `finalAttrs.pname`, so it follows automatically.

### Updating Dependencies

After changing `package.json` or running `pnpm add`/`pnpm remove`:

1. Commit the updated `pnpm-lock.yaml`
1. Clear the `hash` attribute of `pnpmDeps` in `flake.nix`
1. Run `nix build .` and copy the new hash from the error message back into `flake.nix`

### Configuring Vite

Customize `vite.config.ts`:

```typescript
import { svelte } from "@sveltejs/vite-plugin-svelte";
import { defineConfig } from "vite";

export default defineConfig({
  plugins: [svelte()],
  server: {
    port: 3000,
  },
});
```

### Changing the pnpm Version

To use a different pnpm major version (e.g. `pkgs.pnpm_10`):

1. Update both occurrences of the pinned `pnpm` in `flake.nix` (package and dev shell)
1. Regenerate `pnpm-lock.yaml` if the lockfile format changed
1. Regenerate the `pnpmDeps` hash as described above

### Modifying Pre-commit Hooks

Edit the `checks.pre-commit-check.hooks` section in `flake.nix` to enable, disable, or configure hooks.

## Platform Support

This template supports:

- `x86_64-linux`
- `aarch64-linux`
- `x86_64-darwin` (macOS Intel)
- `aarch64-darwin` (macOS Apple Silicon)

## Common Tasks

### Managing Dependencies

```bash
# Add a dependency
pnpm add express

# Add a dev dependency
pnpm add -D vitest

# Remove a dependency
pnpm remove express
```

Remember to regenerate the `pnpmDeps` hash after committing lockfile changes.

### Building for Production

```bash
# Build with Vite
pnpm build

# Or use Nix for reproducible builds
nix build .
```

### Deployment

The Nix-built package can be deployed to any system:

```bash
# Copy to server
nix build .
scp -r result/ server:/opt/myapp

# Or use nix copy
nix copy --to ssh://server ./result
```

## Troubleshooting

### `create-vite` command not found

Ensure you're in the development shell:

```bash
nix develop
# or with direnv:
direnv allow
```

### Vite dev server not starting

1. Check port availability (default: 5173)
1. Ensure all dependencies are installed: `pnpm install`
1. Check for errors in the console

### Build fails with a hash mismatch in Nix

The `pnpmDeps` hash no longer matches `pnpm-lock.yaml`. Clear the hash and rebuild to get the new one:

```bash
nix build .
# Copy the "got:" hash into flake.nix
```

### Pre-commit hooks fail

Run hooks manually to see detailed error messages:

```bash
git commit  # hooks run automatically
# OR
prek run --all-files  # run all hooks manually
```

## References

- [pnpm Documentation](https://pnpm.io)
- [Vite Documentation](https://vitejs.dev/)
- [nixpkgs JavaScript Packaging](https://nixos.org/manual/nixpkgs/stable/#language-javascript)
- [create-vite](https://vitejs.dev/guide/#scaffolding-your-first-vite-project)

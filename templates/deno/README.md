# Deno Development Environment Template

A modern Nix flake template for Deno/Node.js development with Vite integration, pre-commit hooks, and deployment packaging.

## Overview

This template provides a complete Deno-based web development environment with:

- **Deno Runtime**: Modern JavaScript/TypeScript runtime
- **Vite Integration**: Fast build tooling via `create-vite` script
- **Code Quality**: Deno fmt and lint built-in
- **Pre-commit Hooks**: Extensive quality checks including Prettier
- **Package Building**: Complete deployable package with preview server

## Quick Start

Initialize a new Deno project:

```bash
nix flake init --template github:dlubawy/nix-configs/main#deno
```

Enter the development environment:

```bash
nix develop
```

Create a Vite project:

```bash
create-vite
```

## Project Structure

The template provides:

- `flake.nix` - Nix flake configuration with Deno runtime and Vite packaging
- `.envrc` - direnv configuration for automatic environment activation
- `.gitignore` - Pre-configured for Node/Deno projects

After running `create-vite`, you'll have a standard Vite project structure.

## How It Works

### Deno Runtime

The template uses Deno, a modern runtime for JavaScript and TypeScript:

- **Secure by default**: Explicit permissions for file, network, and environment access
- **TypeScript support**: Native TypeScript execution without configuration
- **Web standards**: Built on web platform APIs
- **NPM compatibility**: Can import npm packages via `npm:` specifiers

### Vite Integration

The template includes a helper script `create-vite` that runs:

```bash
deno run -A npm:create-vite .
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

#### After Creating a Vite Project

```bash
# Install dependencies (if using npm packages)
deno install

# Start development server
deno task dev

# Build for production
deno task build

# Preview production build
deno task preview
```

#### Using Deno Directly

```bash
# Run a TypeScript file
deno run main.ts

# Run with permissions
deno run --allow-net --allow-read server.ts

# Format code
deno fmt

# Lint code
deno lint

# Type check without running
deno check main.ts
```

#### Importing NPM Packages

```typescript
// Using npm: specifier
import express from "npm:express@4";

// Or use import maps in deno.json
```

### Building Packages

The template includes a sophisticated Nix package that:

1. Installs dependencies with Deno
1. Runs the Vite build task
1. Creates a deployable package with preview server
1. Includes a wrapper script for serving the built application

#### Building with Nix

```bash
# Build the package
nix build

# Run the packaged application (starts preview server)
./result/bin/template

# Or run directly
nix run
```

The built package includes:

- Compiled Vite application
- Node modules (frozen)
- Preview server configuration
- Wrapper script for deployment

### Pre-commit Hooks

The template includes comprehensive quality checks that run automatically on commit:

- **Security**: `trufflehog` - Detect hardcoded secrets
- **Deno Quality**:
  - `denofmt` - Format TypeScript/JavaScript code
  - `denolint` - Lint code for common issues
- **Nix Quality**: `nixfmt-rfc-style` - Format Nix files
- **Documentation**:
  - `prettier` - Format various file types
  - `mdformat` - Format Markdown files
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
package = {
  pname = "my-app";  # Change this
  version = "0.1.0";
  # ...
};
```

Also update the script name in the wrapper:

```nix
exe="$out"/bin/my-app  # Match pname
```

### Configuring Vite

After creating a Vite project, customize `vite.config.ts`:

```typescript
import { defineConfig } from 'vite'

export default defineConfig({
  // Your configuration
  server: {
    port: 3000,
  },
  build: {
    outDir: 'dist',
  },
})
```

### Adding Deno Configuration

Create a `deno.json` file for Deno-specific configuration:

```json
{
  "tasks": {
    "dev": "deno run -A npm:vite",
    "build": "deno run -A npm:vite build",
    "preview": "deno run -A npm:vite preview"
  },
  "imports": {
    // Import maps
  },
  "fmt": {
    "options": {
      "lineWidth": 100
    }
  },
  "lint": {
    "rules": {
      "tags": ["recommended"]
    }
  }
}
```

### Using Node Instead of Deno

To use Node.js instead:

```nix
buildInputs = with pkgs; [
  nodejs_20  # Instead of deno
];

# Update build phase to use npm/pnpm/yarn
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

### Managing Dependencies

With NPM packages:

```bash
# Using deno install
deno install

# Or with package.json
deno task install
```

### Running Tests

```bash
# Deno native tests
deno test

# Or Vite/Vitest
deno task test
```

### Type Checking

```bash
# Type check without running
deno check **/*.ts

# Or with Vite
deno task typecheck  # If configured
```

### Building for Production

```bash
# Build with Vite
deno task build

# Or with Nix for reproducible builds
nix build
```

### Deployment

The Nix-built package can be deployed to any system:

```bash
# Copy to server
nix build
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

### Permission denied errors with Deno

Deno requires explicit permissions. Use flags like:

- `--allow-read` - File system read
- `--allow-write` - File system write
- `--allow-net` - Network access
- `--allow-env` - Environment variables
- `-A` - Allow all (use sparingly)

### Vite dev server not starting

1. Check port availability (default: 5173)
1. Ensure all dependencies are installed: `deno install`
1. Check for errors in the console

### Build fails in Nix

The Nix build creates temporary directories for Deno. If builds fail:

1. Check the build phase in `flake.nix`
1. Ensure all required files are included in `src`
1. Check that `deno task build` works in dev shell first

### Pre-commit hooks fail

Run hooks manually to see detailed error messages:

```bash
git commit  # hooks run automatically
# OR
pre-commit run --all-files  # run all hooks manually
```

### Type errors with NPM packages

Add type declarations:

```bash
# Using npm types
deno install --allow-scripts npm:@types/node
```

Or configure in `deno.json`:

```json
{
  "compilerOptions": {
    "types": ["npm:@types/node"]
  }
}
```

## References

- [Deno Manual](https://deno.land/manual)
- [Deno Standard Library](https://deno.land/std)
- [Vite Documentation](https://vitejs.dev/)
- [Deno NPM Compatibility](https://deno.land/manual/node)
- [create-vite](https://vitejs.dev/guide/#scaffolding-your-first-vite-project)

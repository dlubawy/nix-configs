# OpenTofu Development Environment Template

A comprehensive Nix flake template for infrastructure-as-code using OpenTofu (Terraform fork) with Terragrunt integration and pre-commit hooks.

## Overview

This template provides a complete infrastructure development environment with:

- **OpenTofu**: Open-source Terraform fork for infrastructure as code
- **Terragrunt**: DRY configuration and orchestration for OpenTofu/Terraform
- **Code Quality**: Built-in formatting and validation
- **Pre-commit Hooks**: Extensive quality checks
- **Nix Language Server**: LSP support for Nix files

## Quick Start

Initialize a new OpenTofu project:

```bash
nix flake init --template github:dlubawy/nix-configs/main#tofu
```

Enter the development environment:

```bash
nix develop
```

Initialize OpenTofu:

```bash
tofu init
```

## Project Structure

The template provides:

- `flake.nix` - Nix flake configuration with OpenTofu and Terragrunt
- `.envrc` - direnv configuration for automatic environment activation
- `.gitignore` - Pre-configured for OpenTofu/Terraform projects

You'll need to create your infrastructure configuration files (`.tf` files).

## How It Works

### OpenTofu

OpenTofu is a community-driven fork of Terraform that maintains compatibility while being truly open-source. It uses the same configuration language and state format as Terraform.

#### Basic Infrastructure File

Create a `main.tf` file:

```hcl
terraform {
  required_version = ">= 1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

resource "aws_instance" "example" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"

  tags = {
    Name = "example-instance"
  }
}
```

### Development Workflow

#### Initialize Project

```bash
# Initialize OpenTofu (downloads providers)
tofu init

# Or with backend configuration
tofu init -backend-config=backend.hcl
```

#### Plan and Apply Changes

```bash
# See what changes will be made
tofu plan

# Save plan to file
tofu plan -out=tfplan

# Apply changes
tofu apply

# Apply saved plan
tofu apply tfplan

# Auto-approve (use carefully)
tofu apply -auto-approve
```

#### Validate and Format

```bash
# Validate configuration
tofu validate

# Format all .tf files
tofu fmt

# Format recursively
tofu fmt -recursive
```

#### Manage State

```bash
# Show current state
tofu show

# List resources in state
tofu state list

# Show specific resource
tofu state show aws_instance.example

# Remove resource from state (doesn't destroy)
tofu state rm aws_instance.example
```

#### Destroy Infrastructure

```bash
# Destroy all resources
tofu destroy

# Destroy specific resource
tofu destroy -target=aws_instance.example
```

### Using Terragrunt

Terragrunt helps keep your OpenTofu/Terraform configurations DRY (Don't Repeat Yourself).

#### Terragrunt Configuration

Create a `terragrunt.hcl` file:

```hcl
# Root terragrunt.hcl
terraform {
  source = "./modules/vpc"
}

inputs = {
  environment = "production"
  region      = "us-west-2"
}

# Remote state configuration
remote_state {
  backend = "s3"
  config = {
    bucket         = "my-terraform-state"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "us-west-2"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
```

#### Terragrunt Commands

```bash
# Initialize with Terragrunt
terragrunt init

# Plan with Terragrunt
terragrunt plan

# Apply with Terragrunt
terragrunt apply

# Run in all subdirectories
terragrunt run-all plan
terragrunt run-all apply
```

### Pre-commit Hooks

The template includes comprehensive quality checks that run automatically on commit:

- **Security**: `trufflehog` - Detect hardcoded secrets
- **OpenTofu Quality**:
  - `terraform-format` - Format `.tf` files
  - `terraform-validate` - Validate configuration syntax
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

**Note**: The hooks use `terraform-*` names but work with OpenTofu since they're command-compatible.

## Customization

### Adding Terraform/OpenTofu Tools

Add more tools to the `packages` list in `flake.nix`:

```nix
packages = builtins.attrValues {
  inherit (pkgs)
  opentofu
  terragrunt
  nil
  nixfmt-rfc-style
  # Add more tools:
  terraform-docs    # Generate documentation
  tflint           # Linter for Terraform/OpenTofu
  tfsec            # Security scanner
  terraform-rover  # Visualize state and config
  ;
};
```

### Using Specific OpenTofu Version

The version comes from nixpkgs. To pin a specific version, override:

```nix
packages = [
  (pkgs.opentofu.overrideAttrs (old: {
    version = "1.6.0";
    # ... additional override config
  }))
];
```

### Configuring Backend

Create a `backend.tf` file:

```hcl
terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "us-west-2"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
```

Or use Terragrunt for DRY backend configuration.

### Modifying Pre-commit Hooks

Edit the `checks.pre-commit-check.hooks` section in `flake.nix` to enable, disable, or configure hooks.

## Platform Support

This template supports:

- `x86_64-linux`
- `aarch64-linux`
- `x86_64-darwin` (macOS Intel)
- `aarch64-darwin` (macOS Apple Silicon)

## Common Tasks

### Multi-Environment Setup

Organize by environment:

```
.
├── environments/
│   ├── dev/
│   │   ├── main.tf
│   │   └── terragrunt.hcl
│   ├── staging/
│   │   ├── main.tf
│   │   └── terragrunt.hcl
│   └── prod/
│       ├── main.tf
│       └── terragrunt.hcl
└── modules/
    ├── vpc/
    ├── ec2/
    └── rds/
```

### Importing Existing Resources

```bash
# Import existing AWS instance
tofu import aws_instance.example i-1234567890abcdef0

# Import with Terragrunt
terragrunt import aws_instance.example i-1234567890abcdef0
```

### Using Workspaces

```bash
# Create workspace
tofu workspace new dev

# List workspaces
tofu workspace list

# Switch workspace
tofu workspace select prod

# Show current workspace
tofu workspace show
```

### Working with Modules

Create reusable modules:

```hcl
# modules/vpc/main.tf
variable "cidr_block" {
  type = string
}

resource "aws_vpc" "main" {
  cidr_block = var.cidr_block
}

output "vpc_id" {
  value = aws_vpc.main.id
}

# Use the module
module "vpc" {
  source     = "./modules/vpc"
  cidr_block = "10.0.0.0/16"
}
```

### Debugging

```bash
# Enable verbose logging
export TF_LOG=DEBUG
tofu plan

# Log to file
export TF_LOG_PATH=./terraform.log
tofu apply

# Disable logging
unset TF_LOG TF_LOG_PATH
```

## Troubleshooting

### `tofu` command not found

Ensure you're in the development shell:

```bash
nix develop
# or with direnv:
direnv allow
```

### Provider download fails

Check your internet connection and provider source:

```bash
# Verify provider configuration
tofu providers

# Clear provider cache
rm -rf .terraform/
tofu init
```

### State lock errors

If state is locked and process died:

```bash
# Force unlock (use with caution)
tofu force-unlock <lock-id>

# Or with Terragrunt
terragrunt force-unlock <lock-id>
```

### Pre-commit validation fails

Ensure configuration is valid before committing:

```bash
tofu init
tofu validate
tofu fmt
```

### Terraform vs OpenTofu compatibility

OpenTofu maintains compatibility with Terraform 1.5.x. Most Terraform modules and providers work without changes. Check the [OpenTofu migration guide](https://opentofu.org/docs/intro/migration/) for details.

### Pre-commit hooks fail

Run hooks manually to see detailed error messages:

```bash
git commit  # hooks run automatically
# OR
pre-commit run --all-files  # run all hooks manually
```

## References

- [OpenTofu Documentation](https://opentofu.org/docs/)
- [OpenTofu vs Terraform](https://opentofu.org/docs/intro/migration/)
- [Terragrunt Documentation](https://terragrunt.gruntwork.io/)
- [Terraform Language](https://developer.hashicorp.com/terraform/language) (compatible with OpenTofu)
- [Terraform Registry](https://registry.terraform.io/) (providers work with OpenTofu)
- [OpenTofu Registry](https://github.com/opentofu/registry)

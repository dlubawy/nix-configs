# Nix Configs Module

This module provides common user definition options and configuration used across both Darwin and NixOS systems. It defines the schema for user accounts that are consumed by platform-specific user management modules.

## Purpose

The nix-configs module establishes a unified interface for defining users with:

- User account information (name, full name, email)
- SSH public key configuration
- GPG public key configuration
- Password management (hashed passwords or password files)

## Usage

Define users in the `./users` directory using the schema provided by this module:

```nix
{
  nix-configs.users.username = {
    name = "username";
    fullName = "Full Name";
    email = "user@example.com";
    sshKey = "ssh-ed25519 AAAA...";
    gpgKey = "fingerprint";
    initialHashedPassword = "hashed-password";  # or
    hashedPasswordFile = "/path/to/password/file";
  };
}
```

## Configuration Options

### `nix-configs.users.<name>`

- `name`: Username (must be < 32 characters, defaults to attribute name)
- `fullName`: User's full name
- `email`: User's email address
- `sshKey`: SSH public key for authorized_keys
- `gpgKey`: GPG public key for encryption/signing
- `initialHashedPassword`: Initial hashed password (created with mkpasswd)
- `hashedPasswordFile`: Path to file containing hashed password

## Password Precedence

Passwords are applied in this order (left to right, right wins):

`name` → `initialHashedPassword` → `hashedPasswordFile`

- On **Darwin**: If no password is set, defaults to the user's `name`
- On **NixOS**: Uses `initialHashedPassword` or `hashedPasswordFile`

## Features

- **Validation**: Username length validation (< 32 characters)
- **Cross-Platform**: Works with both nix-darwin and NixOS user modules
- **Flexible Password Management**: Support for multiple password sources
- **Type Safety**: Strict type checking for all options

## Files

- `nix-configs.nix`: User definition schema
- `default.nix`: Module export

## Related Documentation

- See [modules/darwin](../darwin) for Darwin-specific user management
- See [modules/nixos](../nixos) for NixOS-specific user management  
- See [users/](../../users) for user definitions
- See main [README.md](../../README.md) for password management details

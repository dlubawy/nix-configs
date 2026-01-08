# IMPORTANT: Secret Placeholder

⚠️ **WARNING: This is a PLACEHOLDER secret file** ⚠️

This file contains placeholder data and **MUST** be replaced with a properly encrypted secret before deployment.

## How to Generate and Encrypt the Real Secret

1. Generate a secure random key:
   ```bash
   openssl rand -hex 32
   ```
   Copy the output to your clipboard.

2. Encrypt the file using agenix (this opens your editor):
   ```bash
   cd /path/to/nix-configs
   agenix -e secrets/nextcloud-harp-key.age
   ```

3. In the editor that opens, replace the contents with:
   ```
   HP_SHARED_KEY=<your-generated-key>
   ```
   Replace `<your-generated-key>` with the key from step 1.
   Save and exit.

## What this secret is for

The `HP_SHARED_KEY` is used by the HaRP (High-performance AppAPI Reverse Proxy) container to authenticate with the Nextcloud AppAPI. This key must match between:
- The HaRP container environment (set via this encrypted file)
- The Nextcloud Admin Settings when registering the deploy daemon

## Security Notes

- Keep this key secret and secure
- Use a cryptographically secure random generator (like `openssl rand`)
- Never commit unencrypted secrets to the repository
- The key should be at least 32 bytes (64 hex characters)

For more information, see `hosts/lil-nas/APPAPI_SETUP.md`

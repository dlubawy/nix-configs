# Nextcloud AppAPI with HaRP Configuration

This document explains the changes made to enable Nextcloud AppAPI with HaRP (High-performance AppAPI Reverse Proxy) using Podman.

## Changes Made

### 1. Podman Configuration (`hosts/lil-nas/nextcloud.nix`)

- **Disabled Docker**: Set `virtualisation.docker.enable = false`
- **Enabled Podman**: Configured with `dockerCompat = true` for HaRP compatibility
- **DNS Resolution**: Enabled DNS for containers with `defaultNetwork.settings.dns_enabled = true`
- **OCI Backend**: Set to "podman" for container management

### 2. HaRP Container

Added the HaRP container configuration with:
- Image: `ghcr.io/nextcloud/nextcloud-appapi-harp:release`
- Network: Host networking for simplified communication
- Environment: `NC_INSTANCE_URL = "http://${cloudDomain}"` (uses the configured Nextcloud domain)
- Secret: HP_SHARED_KEY loaded from encrypted file
- Volume: Docker socket mount for Podman compatibility

### 3. Nextcloud Settings

- Enabled `appstoreEnable = true` to allow installing AppAPI from the Nextcloud App Store
- Verified `allow_local_remote_servers = true` is set (already configured)

### 4. Secret Management

- Added `nextcloud-harp-key.age` secret file
- Updated `secrets/secrets.nix` with the new secret definition

## Post-Deployment Steps

After deploying this configuration with `nixos-rebuild switch`, you need to:

### 1. Generate and Encrypt the HP_SHARED_KEY

The placeholder secret file must be replaced with a real encrypted secret:

```bash
# Generate a secure random key
openssl rand -hex 32
# Copy the output to your clipboard

# Encrypt it using agenix (this opens your editor)
cd /path/to/nix-configs
agenix -e secrets/nextcloud-harp-key.age

# In the editor, add the following line (replace <your-generated-key> with the key from above):
# HP_SHARED_KEY=<your-generated-key>
# Save and close the editor
```

### 2. Deploy the Configuration

```bash
sudo nixos-rebuild switch --flake /path/to/nix-configs#lil-nas
```

### 3. Install AppAPI from Nextcloud App Store

1. Log in to your Nextcloud instance as admin
2. Go to Apps → "App bundles" or "Tools"
3. Find and install "AppAPI"
4. Enable the app

### 4. Register the HaRP Daemon

1. Go to Nextcloud Admin Settings → "AppAPI"
2. Click "Register Deploy Daemon"
3. Enter the following details:
   - **Display Name**: "HaRP"
   - **Host**: `http://localhost:8780`
   - **Shared Secret**: (The HP_SHARED_KEY you generated)
   - **Deploy Method**: `docker_install`
   - **Network**: Leave default or set to appropriate network
4. Save the configuration

### 5. Test with an External App

Try installing an AI app to verify the setup:
1. Go to Apps → Browse and enable
2. Search for "Translate" or "LLM2"
3. Install the app
4. Check that the container is deployed successfully

## Troubleshooting

### Check HaRP Container Status

```bash
sudo podman ps | grep harp
sudo journalctl -u podman-harp.service -f
```

### Check Podman Socket

```bash
ls -la /var/run/docker.sock
sudo systemctl status podman.socket
```

### Verify DNS Resolution

```bash
sudo podman run --rm alpine nslookup google.com
```

### Check AppAPI Logs in Nextcloud

Go to Settings → Administration → Logging and filter for AppAPI-related entries.

## Architecture

```
Nextcloud (localhost)
    ↓
HaRP Container (localhost:8780)
    ↓ docker.sock (Podman compatibility)
Podman
    ↓
External Apps Containers
```

## Security Notes

- The HP_SHARED_KEY must be kept secret and properly encrypted using agenix
- HaRP uses host networking for simplified communication
- SELinux labels are disabled on the container for compatibility
- All external app containers are managed by Podman in rootless mode when possible

## References

- [Nextcloud AppAPI Documentation](https://github.com/nextcloud/app_api)
- [HaRP Repository](https://github.com/nextcloud/nextcloud-appapi-harp)
- [NixOS Podman Configuration](https://nixos.wiki/wiki/Podman)

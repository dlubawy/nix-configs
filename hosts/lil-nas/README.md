# GMKtec G9

![Main Topology](../../assets/topology-main.svg)
![Network Topology](../../assets/topology-network.svg)

This is a home NAS server running on a GMKtec G9 mini PC with Intel hardware. It provides several services including Nextcloud for personal cloud storage, Jellyfin for media streaming, and monitoring services (Grafana, Loki, Prometheus).

## Hardware

- Intel CPU with hardware graphics acceleration (Intel Media Driver - iHD)
- eMMC boot drive
- Two NVMe SSDs in ZFS mirror configuration
- Connected to LAN via Ethernet

## Services

- **Nextcloud**: Personal cloud storage with Collabora Online for document editing
- **Jellyfin**: Media server with Tailscale drive sharing and hardware acceleration
- **Grafana**: Monitoring dashboards with alerting
- **Loki**: Log aggregation
- **Prometheus**: Metrics collection
- **Tailscale**: Secure networking
- **Avahi**: mDNS service discovery
- **SSH**: Remote access (key-based authentication only)

## Installation

Installation assumes a GMKtec G9 or similar x86_64 Intel-based system with eMMC and two NVMe drives for ZFS storage.

- Clone this repo: `git clone https://github.com/dlubawy/nix-configs.git`
- Enter where the repo was cloned: `cd nix-configs`
- Add or modify any users wanting to use the system in the `./users` module
  - Modify the `imports` to include/exclude the users for the system
- Edit `vars` in `flake.nix` to use your desired user's email acting as the system admin (used for ACME cert management)
- Change any static network configurations and passwords using `agenix`
- Run `make lil-nas` to build and switch to the configuration on an existing installation

## Storage

The system uses ZFS with two pools:

- **rpool**: System root on eMMC with ephemeral root using rollback to `@blank` snapshot
- **tank**: Two NVMe SSDs in mirror configuration for persistent data
  - `/nix`: Nix store
  - `/home`: User home directories
  - `/persist`: Persistent system state
  - `/srv/jellyfin`: Jellyfin media storage
  - `/var/lib/postgresql`: PostgreSQL database for Nextcloud
  - `/var/lib/nextcloud`: Nextcloud data

Both pools use encryption with passphrase unlock on boot, ZSTD compression, and automatic snapshots on the tank pool.

## Notes

- Shadow password management is enabled with per-user `~/.shadow` files
- Preservation module is enabled for maintaining state across ephemeral root reboots
- Nextcloud and Collabora domains can be configured via `cloudDomain` and `collaboraDomain` options
- Grafana dashboards include monitoring for DHCP, firewall, Nextcloud, system metrics, SSH, sudo logs, and ZFS

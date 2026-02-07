# Banana Pi BPI-R3

![Main Topology](../../assets/topology-main.svg)
![Network Topology](../../assets/topology-network.svg)

This makes use of [nakato/nixos-sbc](https://github.com/nakato/nixos-sbc) for creating the boot image of the router. I am not a network security expert, so this configuration does not guarantee security. I made the best attempt with the skills I possess; all feedback welcome. Goal of the router is to primary segment LAN users through four VLAN: `vl-lan`, `vl-user`, `vl-iot`, and `vl-guest`.

- LAN network acts as a management interface to the router and networks themselves.
- USER network provides trusted networking that can reach into the IOT and GUEST networks but not the reverse.
- IOT provides a downgraded Wi-Fi security entry point and a dedicated 2.4GHz connection for devices that have poor update support.
- GUEST provides an entry point for all devices not registered in the dynamic VLAN configuration for hostapd. **NOTE:** devices on the GUEST network may talk to each other due to hostapd `ap_isolate` not working with dynamic VLAN. This is due to MAC address routing bypassing forwarding rules in nftables on the WLAN interface that is dynamically created. GUEST devices will **not** be able to talk outside the VLAN though (except for a set aside subnet into the IOT network).

Installation assumes an assembled Banana Pi BPI-R3 without any additional PCI devices and only an SD card.

- Clone this repo: `git clone https://github.com/dlubawy/nix-configs.git`
- Enter where the repo was cloned: `cd nix-configs`
- Add or modify any users wanting to use the system in the `./users` module
  - Modify the `imports` to include/exclude the users for the system
- Edit `vars` in `flake.nix` to use your desired user's email acting as the system admin (used for ACME cert management)
- Change any static network configurations such as DHCP leases and passwords using `agenix`
- Run `just image bpi` to build the initial SD card image or run `just build switch bpi` to build the image from an existing installation.
- Using a 32 GB+ SD card (skip if using an existing bpi image)
  - Insert the SD and figure out the appropriate disk device (`fdisk` on Linux or `diskutil` on macOS)
  - Run `nix run nixpkgs#zstdcat ./result/sd-image/nixos-sd-image-*.zst | dd of=<disk> status=progress bs=64M`
  - Insert SD card and boot the Banana Pi
- Connect to the BPI using an Ethernet cable to one of the LAN 1--4 ports or use an SPI connection (Wi-Fi cannot start if SPI is connected)
- Change the initial password with `passwd`
- Login to Grafana (user: `admin`, password: `admin`) and change the admin password

## Notes

- Linux kernel: needs a custom linux kernel patch to get 2.5G SFP module working.
- hostapd: there is a bug with hostapd that breaks VLAN interface assignment when using a PMKSA cache. This cache is required for 5G and Apple device authentication to work, so a patch is applied to effectively disable the cache without removing the PMKID handling and other cache logic.

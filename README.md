[![Cache 📝](https://github.com/dlubawy/nix-configs/actions/workflows/cache.yaml/badge.svg)](https://github.com/dlubawy/nix-configs/actions/workflows/cache.yaml)
[![Format 🔎](https://github.com/dlubawy/nix-configs/actions/workflows/format.yaml/badge.svg)](https://github.com/dlubawy/nix-configs/actions/workflows/format.yaml)
[![Update ⬆️](https://github.com/dlubawy/nix-configs/actions/workflows/update.yaml/badge.svg)](https://github.com/dlubawy/nix-configs/actions/workflows/update.yaml)

# nix-configs

My personal Nix configurations.

## Notes

These configurations make use of personal preferences. I have forked some tools and made personal edits which may make this unstable:

- `nix-darwin`: I added additional user configuration management and fixed some multi-user issues in the system. This was done in a heavy-handed manner and so will likely not be supported upstream. This may change as upstream improves on these issues.
- `agenix`: Wanted to add armor output support for better git visibility. Also needed to fix `ageBin` for Darwin configuration.

## Setup

### macOS

This assumes starting from a fresh installation of macOS before initial setup and attempts to follow best practices as laid out in [drduh's macOS Security and Privacy Guide](https://github.com/drduh/macOS-Security-and-Privacy-Guide). It is possible to start after initial setup but assuming a setup without admin/user separation then the admin account will need to be created, and the regular user demoted from the admin group.

- Create the admin user which will manage the OS and Nix: `laplace`
  - If demoting a regular user after creating the admin account, log out of the regular user and into the new admin account to run:
    ```
    sudo dscl . -delete /Groups/admin GroupMembership <username>
    sudo dscl . -delete /Groups/admin GroupMembers <GeneratedUID>
    ```
  - To find the `GeneratedUID` of an account:
    ```
    dscl . -read /Users/<username> GeneratedUID
    ```
- Rename the computer `System Settings -> General -> About -> Name`: `laplace`
- [Install Nix](https://nix.dev/install-nix#install-nix)
- [Install Homebrew](https://brew.sh/)
- Clone this repo in `/Users/Shared/`: `git clone https://github.com/dlubawy/nix-configs.git /Users/Shared/nix`
- Enter where the repo was cloned: `cd /Users/Shared/nix`
- Edit `vars` in `flake.nix` to use your desired name, email, user, and public keys
- As admin user (`laplace`), run the initial `nix --extra-experimental-features 'nix-command flakes' run nix-darwin -- switch --flake .#laplace`
  - The normal user may subsequently run the command with sudo `sudo -Hu laplace darwin-rebuild switch --flake .#laplace`
  - A `make` command is supplied to make this easier: `make laplace`
  - You may want to change the `shellAlias` for `laplace` to point to your own repo with any changes;
    Then you may run `laplace` as a command alias for rebuilding from the remote.

### Raspberry Pi

This assumes a working Nix installation on a separate computer for building manually. Otherwise, one may follow the [ARM installation guide](https://nixos.wiki/wiki/NixOS_on_ARM#Installation) to install on the board first and then follow the instructions given here.

- Clone this repo: `git clone https://github.com/dlubawy/nix-configs.git`
- Enter where the repo was cloned: `cd nix-configs`
- Edit `vars` in `flake.nix` to use your desired name, email, user, and public keys
- Run `make pi-image` to build the initial SD card image or run `make pi` to build the image from an existing installation.
- Using a 32 GB+ SD card (skip if using an existing pi image)
- - Insert the SD and figure out the appropriate disk device (`fdisk` on Linux or `diskutil` on macOS)
- - Run `nix run nixpkgs#zstdcat ./result/sd-image/nixos-sd-image-*.zst | dd of=<disk> status=progress bs=64M`
- - Insert SD card and boot the Raspberry Pi
- Login to the user defined previously using username as initial password then change the password with `passwd`

### WSL

This assumes a working Nix installation on the target platform (`x86_64-linux`). Can run this from a temporary NixOS-WSL image built following [these instructions](https://nix-community.github.io/NixOS-WSL/install.html).

- Run `sudo nix run github:dlubawy/nix-configs/main#nixosConfigurations.syringa.config.system.build.tarballBuilder`
- Install the resulting tarball from inside a PowerShell terminal on the target: `wsl --import NixOS $env:USERPROFILE\NixOS\ nixos-wsl.tar.gz`
- Add [Catppuccin theme for Windows Terminal](https://github.com/catppuccin/windows-terminal/tree/main)
- Install [FantasqueSansMono Nerd Font](https://github.com/ryanoasis/nerd-fonts/releases) on Windows and select it as font

### Banana Pi BPI-R3

![Network Topology](./assets/network-topology.svg)

This makes use of [nakato/nixos-sbc](https://github.com/nakato/nixos-sbc) for creating the boot image of the router. I am not a network security expert, so this configuration does not guarantee security. I made the best attempt with the skills I possess; all feedback welcome. Goal of the router is to primary segment LAN users through four VLAN: `vl-lan`, `vl-user`, `vl-iot`, and `vl-guest`.

- LAN network acts as a management interface to the router and networks themselves.
- USER network provides trusted networking that can reach into the IOT and GUEST networks but not the reverse.
- IOT provides a downgraded Wi-Fi security entry point and a dedicated 2.4GHz connection for devices that have poor update support.
- GUEST provides an entry point for all devices not registered in the dynamic VLAN configuration for hostapd. *NOTE:* devices on the GUEST network may talk to each other due to hostapd `ap_isolate` not working with dynamic VLAN. This is due to MAC address routing bypassing forwarding rules in nftables on the WLAN interface that is dynamically created. GUEST devices will **not** be able to talk outside the VLAN though (except for a set aside subnet into the IOT network).

Installation assumes an assembled Banana Pi BPI-R3 without any additional PCI devices and only an SD card.

- Clone this repo: `git clone https://github.com/dlubawy/nix-configs.git`
- Enter where the repo was cloned: `cd nix-configs`
- Edit `vars` in `flake.nix` to use your desired name, email, user, and public keys
- Change any static network configurations such as DHCP leases and passwords using `agenix`
- Run `make bpi-image` to build the initial SD card image or run `make bpi` to build the image from an existing installation.
- Using a 32 GB+ SD card (skip if using an existing bpi image)
  - Insert the SD and figure out the appropriate disk device (`fdisk` on Linux or `diskutil` on macOS)
  - Run `nix run nixpkgs#zstdcat ./result/sd-image/nixos-sd-image-*.zst | dd of=<disk> status=progress bs=64M`
  - Insert SD card and boot the Banana Pi
- Connect to the BPI using an Ethernet cable to one of the LAN 1--4 ports or use an SPI connection (Wi-Fi cannot start if SPI is connected)
- Change the initial password with `passwd`
- Login to Grafana (user: `admin`, password: `admin`) and change the admin password

#### Notes

- Linux kernel: needs a custom linux kernel patch to get 2.5G SFP module working.
- hostapd: there is a bug with hostapd that breaks VLAN interface assignment when using a PMKSA cache. This cache is required for 5G and Apple device authentication to work, so a patch is applied to effectively disable the cache without removing the PMKID handling and other cache logic.

### Templates

Use any template to create a nix flake based development environment with:

```
nix flake init --template github:dlubawy/nix-configs/main#[template]
```

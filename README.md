# nix-configs
My personal Nix configurations

## Setup
### macOS
This assumes starting from a fresh installation of macOS before initial setup and attempts to follow best practices as laid out in [drduh's macOS Security and Privacy Guide](https://github.com/drduh/macOS-Security-and-Privacy-Guide). It is possible to start after initial setup but assuming a setup without admin/user separation then the admin account will need to be created, and the regular user demoted from the admin group.

* Create the admin user which will manage the OS and Nix: `laplace`
  - If demoting a regular user after creating the admin account, log out of the regular user and into the new admin account to run:
    ```
    sudo dscl . -delete /Groups/admin GroupMembership <username>
    sudo dscl . -delete /Groups/admin GroupMembers <GeneratedUID>
    ```
  - To find the GeneratedUID of an account:
    ```
    dscl . -read /Users/<username> GeneratedUID
    ```
* Rename the computer `System Settings -> General -> About -> Name`: `laplace`
* [Install Nix](https://nix.dev/install-nix#install-nix)
* [Install Homebrew](https://brew.sh/)
* Clone this repo: `git clone https://github.com/dlubawy/nix-configs.git`
* Edit `vars` in `flake.nix` to use your desired name, email, user, and ssh public key
* As admin user, run the initial `nix --extra-experimental-features 'nix-command flakes' run nix-darwin -- switch --flake .#laplace`
  - Regular user may subsequently run command with sudo `sudo -Hu laplace darwin-rebuild switch --flake .#laplace`

### Templates
Use any template to create a nix flake based development environment with:
```
nix flake init --template github:dlubawy/nix-configs/main#[template]
```

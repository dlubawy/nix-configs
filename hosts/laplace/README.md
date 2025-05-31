# MacBook Pro M1

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
- Add or modify any users wanting to use the system in the `./users` module
  - Modify the `imports` to include/exclude the users for the system
- As admin user (`laplace`), run the initial `nix --extra-experimental-features 'nix-command flakes' run nix-darwin -- switch --flake .#laplace`
  - The normal user may subsequently run the command with `sudo -Hu laplace darwin-rebuild switch --flake .#laplace`
  - An alias `laplace` is created to run the command against the remote flake set in the `vars`.
  - A `make` command is supplied to make this easier: `make laplace`
  - You may want to change the `shellAlias` for `laplace` to point to your own repo with any changes;
    Then you may run `laplace` as a command alias for rebuilding from the remote.

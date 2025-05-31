# WSL

This assumes a working Nix installation on the target platform (`x86_64-linux`). Can run this from a temporary NixOS-WSL image built following [these instructions](https://nix-community.github.io/NixOS-WSL/install.html).

- Run `sudo nix run github:dlubawy/nix-configs/main#nixosConfigurations.syringa.config.system.build.tarballBuilder`
- Install the resulting tarball from inside a PowerShell terminal on the target: `wsl --import NixOS $env:USERPROFILE\NixOS\ nixos-wsl.tar.gz`
- Add [Catppuccin theme for Windows Terminal](https://github.com/catppuccin/windows-terminal/tree/main)
- Install [FantasqueSansMono Nerd Font](https://github.com/ryanoasis/nerd-fonts/releases) on Windows and select it as font

{
  lib,
  config,
  inputs,
  ...
}:
{
  imports = [
    inputs.nixos-wsl.nixosModules.default
    ../../users/drew.nix
  ];

  # NOTE: disable so WSL can work
  boot.initrd.systemd.enable = lib.mkForce false;
  systemd.sysusers.enable = lib.mkForce false;
  system.etc.overlay.enable = lib.mkForce false;
  networking.wireless.enable = lib.mkForce false;
  services.resolved.enable = false;

  wsl =
    let
      username = (builtins.head (lib.attrNames config.nix-configs.users));
    in
    {
      enable = true;
      defaultUser = "${username}";
    };

  home-manager = {
    gui.enable = false;
  };
}

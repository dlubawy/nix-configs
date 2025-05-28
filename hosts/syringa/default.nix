{
  lib,
  inputs,
  outputs,
  vars,
  ...
}:
{
  imports = [
    inputs.nixos-wsl.nixosModules.default
  ];

  # NOTE: disable so WSL can work
  boot.initrd.systemd.enable = lib.mkForce false;
  systemd.sysusers.enable = lib.mkForce false;
  system.etc.overlay.enable = lib.mkForce false;

  wsl = {
    enable = true;
    defaultUser = "${vars.user}";
  };

  home-manager.users.${vars.user}.gui.enable = false;
}

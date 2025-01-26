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
    ../../nixos
  ];

  # NOTE: disable so WSL can work
  boot.initrd.systemd.enable = lib.mkForce false;
  systemd.sysusers.enable = lib.mkForce false;
  system.etc.overlay.enable = lib.mkForce false;

  wsl = {
    enable = true;
    defaultUser = "${vars.user}";
  };

  home-manager = {
    extraSpecialArgs = {
      inherit inputs outputs vars;
    };
    users.${vars.user}.gui.enable = false;
  };
}

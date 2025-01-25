{
  inputs,
  outputs,
  vars,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ../../nixos
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  nix = {
    settings = {
      trusted-users = [
        "root"
        "@wheel"
      ];
    };
  };

  networking = {
    hostName = "nix-builder";
    networkmanager.enable = true;
  };

  time.timeZone = "America/Los_Angeles";
  i18n.defaultLocale = "en_US.UTF-8";

  services.openssh.enable = true;

  home-manager = {
    extraSpecialArgs = {
      inherit inputs outputs vars;
      enableGUI = false;
    };
  };
}

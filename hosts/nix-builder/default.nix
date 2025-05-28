{
  inputs,
  outputs,
  vars,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  nix = {
    settings = {
      cores = 8;
      max-jobs = 1;
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

  services = {
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
      };
    };
  };

  home-manager.users.${vars.user}.gui.enable = false;
}

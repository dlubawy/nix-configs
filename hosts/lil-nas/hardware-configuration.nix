{ modulesPath, ... }:
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  # FIXME: qemu VM test
  boot = {
    initrd = {
      availableKernelModules = [
        "ahci"
        "xhci_pci"
        "virtio_pci"
        "virtio_scsi"
        "usb_storage"
        "sd_mod"
      ];
    };
    kernelModules = [ "kvm-amd" ];
  };

  fileSystems = {
    "/" = {
      device = "rpool/local/root";
      fsType = "zfs";
      options = [ "zfsutil" ];
    };
    "/nix" = {
      device = "tank/local/nix";
      fsType = "zfs";
      options = [ "zfsutil" ];
    };
    "/home" = {
      device = "tank/safe/home";
      fsType = "zfs";
      options = [ "zfsutil" ];
      # Needed for userborn when `users.shadow.enable = true`
      neededForBoot = true;
    };
    "/persist" = {
      device = "tank/safe/persist";
      fsType = "zfs";
      options = [ "zfsutil" ];
      neededForBoot = true;
    };
    "/boot" = {
      device = "/dev/disk/by-partlabel/disk-emmc-ESP";
      fsType = "vfat";
      options = [
        "fmask=0022"
        "dmask=0022"
      ];
    };
  };

  zramSwap = {
    enable = true;
    writebackDevice = "/dev/zvol/tank/local/swap";
  };
}

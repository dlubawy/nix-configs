# FIXME: qemu VM test - replace with real hardware config later
{ modulesPath, ... }:
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

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
}

{
  pkgs,
  config,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    secure.enable = true;
    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "nvme"
        "usb_storage"
        "usbhid"
        "sd_mod"
        "sdhci_pci"
      ];
    };
    kernelModules = [ "kvm-intel" ];
  };

  networking.useDHCP = true;
  nixpkgs.hostPlatform = "x86_64-linux";
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
  };
  hardware = {
    cpu.intel.updateMicrocode = config.hardware.enableRedistributableFirmware;
    graphics = {
      enable = true;
      extraPackages = builtins.attrValues {
        inherit (pkgs)
          intel-media-driver
          intel-compute-runtime
          vpl-gpu-rt
          ;
      };
    };
  };
}

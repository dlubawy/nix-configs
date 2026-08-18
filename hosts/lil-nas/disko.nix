{
  config,
  ...
}:
{
  networking.hostId = "d4986fb2";
  disko = {
    enable = true;
    persist.enable = true;
    swap.enable = true;
    zfs = {
      enable = true;
      tank = {
        enable = true;
        mirrors = [
          [
            config.disko.devices.disk.ssd1.device
            config.disko.devices.disk.ssd2.device
          ]
          [
            config.disko.devices.disk.ssd3.device
            config.disko.devices.disk.ssd4.device
          ]
        ];
      };
      localBackup = {
        enable = true;
        device = config.disko.devices.disk.external.device;
      };
      key.enable = true;
    };
    devices = {
      disk = {
        emmc = {
          type = "disk";
          device = "/dev/disk/by-id/mmc-TWSC_0x1b2108a7";
          content = {
            type = "gpt";
            partitions = {
              ESP = {
                size = "1G";
                type = "ef00";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                  mountOptions = [
                    "dmask=0022"
                    "fmask=0022"
                  ];
                };
              };
              root = {
                size = "100%";
                content = {
                  type = "zfs";
                  pool = "rpool";
                };
              };
            };
          };
        };
        ssd1 = {
          type = "disk";
          device = "/dev/disk/by-id/nvme-TWSC_TSC3AN512-F5T50S_TTSMA254GX00859";
          content = {
            type = "zfs";
            pool = "tank";
          };
        };
        ssd2 = {
          type = "disk";
          device = "/dev/disk/by-id/nvme-CT500P310SSD8_2518500D9211";
          content = {
            type = "zfs";
            pool = "tank";
          };
        };
        ssd3 = {
          type = "disk";
          device = "/dev/disk/by-id/nvme-CT2000P310SSD8_2520501B3515";
          content = {
            type = "zfs";
            pool = "tank";
          };
        };
        ssd4 = {
          type = "disk";
          device = "/dev/disk/by-id/nvme-CT2000P310SSD8_2520501B3375";
          content = {
            type = "zfs";
            pool = "tank";
          };
        };
        external = {
          type = "disk";
          device = "/dev/disk/by-id/ata-WDC_WD60EZAZ-00ZGHB0_WD-WX51D68DLVFJ";
          content = {
            type = "zfs";
            pool = "backup";
          };
        };
      };
    };
  };
}

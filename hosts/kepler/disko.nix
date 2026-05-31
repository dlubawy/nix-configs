{ ... }:
{
  networking.hostId = "933cf1f7";

  disko = {
    enable = true;
    swap.enable = true;
    zfs.enable = true;
    memSize = 4 * 1024;
    devices = {
      disk = {
        ssd = {
          type = "disk";
          device = "/dev/nvme0n1";
          imageSize = "50G";
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
      };
      zpool = {
        rpool = {
          options.ashift = "12";
          datasets = {
            "safe" = {
              type = "zfs_fs";
              options.copies = "2";
            };
          };
        };
      };
    };
  };
}

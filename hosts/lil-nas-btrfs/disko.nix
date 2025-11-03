{ inputs, ... }:
{
  imports = [ inputs.disko.nixosModules.disko ];
  disko = {
    devices = {
      disk = {
        root1 = {
          type = "disk";
          device = "/dev/sda";
          content = {
            type = "gpt";
            partitions = {
              boot1 = {
                size = "1G";
                type = "ef00";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                  mountOptions = [
                    "fmask=0022"
                    "dmask=0022"
                  ];
                };
              };
              swap1 = {
                size = "4G";
                type = "8200";
                content = {
                  type = "swap";
                  randomEncryption = true;
                  mountOptions = [ "nofail" ];
                };
              };
              cryptRoot1 = {
                size = "100%";
                content = {
                  type = "luks";
                  name = "enc1";
                };
              };
            };
          };
        };
        root2 = {
          type = "disk";
          device = "/dev/sdb";
          content = {
            type = "gpt";
            partitions = {
              boot1 = {
                size = "1G";
                type = "ef00";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/.bootbackup";
                  mountOptions = [
                    "fmask=0022"
                    "dmask=0022"
                    "nofail"
                  ];
                };
              };
              swap2 = {
                size = "4G";
                type = "8200";
                content = {
                  type = "swap";
                  randomEncryption = true;
                  mountOptions = [ "nofail" ];
                };
              };
              cryptRoot2 = {
                size = "100%";
                content = {
                  type = "luks";
                  name = "enc2";
                  content = {
                    type = "btrfs";
                    extraArgs = [
                      "-d raid1 -m raid1"
                      "/dev/mapper/enc1"
                    ];
                    subvolumes = {
                      "/root" = {
                        mountPoint = "/";
                        mountOptions = [
                          "compress=zstd"
                        ];
                      };
                      "/nix" = {
                        mountPoint = "/nix";
                        mountOptions = [
                          "compress=zstd"
                          "noatime"
                        ];
                      };
                      "/home" = {
                        mountPoint = "/home";
                        mountOptions = [
                          "compress=zstd"
                        ];
                      };
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}

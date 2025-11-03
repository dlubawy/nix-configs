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
              # swap1 = {
              #   size = "4G";
              #   type = "8200";
              #   content = {
              #     type = "swap";
              #     randomEncryption = true;
              #     mountOptions = [ "nofail" ];
              #   };
              # };
              root1 = {
                size = "100%";
                content = {
                  type = "zfs";
                  pool = "zroot";
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
              # swap2 = {
              #   size = "4G";
              #   type = "8200";
              #   content = {
              #     type = "swap";
              #     randomEncryption = true;
              #     mountOptions = [ "nofail" ];
              #   };
              # };
              root2 = {
                size = "100%";
                content = {
                  type = "zfs";
                  pool = "zroot";
                };
              };
            };
          };
        };
      };
      zpool = {
        zroot = {
          type = "zpool";
          mode = {
            topology = {
              type = "topology";
              vdev = [
                {
                  mode = "mirror";
                  members = [
                    "root1"
                    "root2"
                  ];
                }
              ];
            };
          };
          rootFsOptions = {
            mountpoint = "none";
            compression = "zstd";
            acltype = "posixacl";
            xattr = "sa";
            "com.sun:auto-snapshot" = "true";
          };
          options.ashift = 12;
          datasets = {
            "root" = {
              type = "zfs_fs";
              mountpoint = "/";
              options = {
                encryption = "aes-256-gcm";
                keyformat = "passphrase";
                keylocation = "prompt";
              };
            };
            "root/home" = {
              type = "zfs_fs";
              mountpoint = "/home";
            };
            "root/nix" = {
              type = "zfs_fs";
              mountpoint = "/nix";
            };
            "root/var" = {
              type = "zfs_fs";
              mountpoint = "/var";
            };
            "root/swap" = {
              type = "zfs_volume";
              size = "8G";
              content = {
                type = "swap";
              };
              options = {
                volblocksize = "4096";
                compression = "zle";
                logbias = "throughput";
                sync = "always";
                primarycache = "metadata";
                secondarycache = "none";
                "com.sun:auto-snapshot" = "false";
              };
            };
          };
        };
      };
    };
  };
}

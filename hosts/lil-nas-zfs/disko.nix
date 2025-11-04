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
              ESP = {
                size = "1G";
                type = "ef00";
                content = {
                  type = "mdraid";
                  name = "boot";
                };
              };
              zfs = {
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
              ESP = {
                size = "1G";
                type = "ef00";
                content = {
                  type = "mdraid";
                  name = "boot";
                };
              };
              zfs = {
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
      mdadm = {
        boot = {
          type = "mdadm";
          level = 1;
          metadata = "1.0";
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
          options.ashift = "12";
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

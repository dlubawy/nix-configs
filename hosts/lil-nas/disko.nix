{ pkgs, inputs, ... }:
{
  imports = [ inputs.disko.nixosModules.disko ];

  # Needed if doing mdadm raid1 on /boot
  # environment.variables = {
  #   SYSTEMD_RELAX_ESP_CHECKS = 1;
  # };

  networking.hostId = "d4986fb2";
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    initrd.systemd.services."zfs-rollback" = {
      description = "Rollback root ZFS dataset to snapshot before mounting root";
      wantedBy = [ "initrd.target" ];
      before = [ "sysroot.mount" ];
      after = [ "zfs-import-rpool.service" ];

      path = [ pkgs.zfs ];
      unitConfig.DefaultDependencies = "no";
      serviceConfig.Type = "oneshot";
      script = "zfs rollback -r rpool/local/root@blank";
    };
  };

  fileSystems."/persist" = {
    neededForBoot = true;
  };

  zramSwap = {
    enable = true;
    writebackDevice = "/dev/zvol/tank/local/swap";
  };

  disko = {
    devices = {
      disk = {
        emmc = {
          type = "disk";
          device = "/dev/mmcblk0";
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
          device = "/dev/nvme0n1";
          content = {
            type = "zfs";
            pool = "tank";
          };
        };
        ssd2 = {
          type = "disk";
          device = "/dev/nvme1n1";
          content = {
            type = "zfs";
            pool = "tank";
          };
        };
      };
      zpool = {
        rpool = {
          type = "zpool";
          rootFsOptions = {
            encryption = "on";
            keyformat = "passphrase";
            keylocation = "prompt";
            mountpoint = "none";
            compression = "zstd";
            acltype = "posixacl";
            xattr = "sa";
            "com.sun:auto-snapshot" = "false";
          };
          datasets = {
            "local/root" = {
              type = "zfs_fs";
              mountpoint = "/";
              postCreateHook = "zfs list -t snapshot -H -o name | grep -E '^rpool/local/root@blank$' || zfs snapshot rpool/local/root@blank";
            };
          };
        };
        tank = {
          type = "zpool";
          mode = {
            topology = {
              type = "topology";
              vdev = [
                {
                  mode = "mirror";
                  members = [
                    "ssd1"
                    "ssd2"
                  ];
                }
              ];
            };
          };
          rootFsOptions = {
            encryption = "on";
            keyformat = "passphrase";
            keylocation = "prompt";
            mountpoint = "none";
            compression = "zstd";
            acltype = "posixacl";
            xattr = "sa";
            "com.sun:auto-snapshot" = "true";
          };
          options.ashift = "12";
          datasets = {
            "local/nix" = {
              type = "zfs_fs";
              mountpoint = "/nix";
              options = {
                "com.sun:auto-snapshot" = "false";
              };
            };
            "safe/home" = {
              type = "zfs_fs";
              mountpoint = "/home";
            };
            "safe/persist" = {
              type = "zfs_fs";
              mountpoint = "/persist";
            };
            "local/swap" = {
              type = "zfs_volume";
              size = "4G";
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

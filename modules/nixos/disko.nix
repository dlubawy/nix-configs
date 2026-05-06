{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  inherit (lib)
    mkIf
    mkEnableOption
    mkOption
    mkMerge
    optionals
    optionalString
    types
    lists
    ;
  cfg = config.disko;
in
{
  imports = [ inputs.disko.nixosModules.disko ];

  options = {
    disko = {
      enable = mkEnableOption "Enable disko module";
      persist = {
        enable = mkEnableOption "Enable persist dataset setup";
      };
      swap = {
        enable = mkEnableOption "Enable swap configurations";
        size = mkOption {
          description = "Size of swap to use";
          default = "4G";
          type = types.str;
        };
      };
      zfs = {
        enable = mkEnableOption "Enable ZFS configurations";
        tank = {
          enable = mkEnableOption "Enable ZFS tank pool for data storage";
          mirrors = mkOption {
            description = "List of mirrored pairs";
            type = types.listOf (types.listOf types.str);
          };
        };
        key = {
          enable = mkEnableOption "Enable using a device key for drive unlock";
          device = mkOption {
            description = "Device key to use for unlocking zfs pool";
            default = "/dev/disk/by-partlabel/zfs-key";
            type = types.str;
          };
        };
        # TODO: expand this to setup the raid config too
        bootRaid.enable = mkEnableOption "Enable using RAID1 on /boot";
      };
    };
  };
  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.zfs.enable -> (config.networking.hostId != null);
        message = "Must set hostId when using ZFS with disko. Use 'head -c4 /dev/urandom | od -A none -t x4' to generate one.";
      }
      {
        assertion = cfg.enable -> ((lists.count (x: x) [ cfg.zfs.enable ]) == 1);
        message = "Only one filesystem can be configured at a time with disko";
      }
      {
        assertion = (cfg.zfs.tank.enable) -> (lists.length cfg.zfs.tank.mirrors > 0);
        message = "Must have configured devices for vdev mirrors";
      }
    ];

    environment.variables = mkIf cfg.zfs.bootRaid.enable {
      SYSTEMD_RELAX_ESP_CHECKS = 1;
    };

    boot = {
      loader = {
        efi.canTouchEfiVariables = true;
      };

      initrd.systemd.services = {
        "zfs-wait" = mkIf (cfg.persist.enable && cfg.zfs.enable && cfg.zfs.key.enable) {
          description = "Wait for ZFS key to unlock pools";
          wantedBy = [ "initrd.target" ];
          before = [
            "zfs-import-rpool.service"
          ]
          ++ (optionals cfg.zfs.tank.enable [
            "zfs-import-tank.service"
          ]);
          after = [ "initrd-root-device.target" ];

          unitConfig.DefaultDependencies = "no";
          serviceConfig.Type = "oneshot";
          script = "udevadm wait ${cfg.zfs.key.device}";
        };
        "zfs-rollback" = mkIf (cfg.persist.enable && cfg.zfs.enable) {
          description = "Rollback root ZFS dataset to snapshot before mounting root";
          wantedBy = [ "initrd.target" ];
          before = [ "sysroot.mount" ];
          after = [ "zfs-import-rpool.service" ];

          path = [ pkgs.zfs ];
          unitConfig.DefaultDependencies = "no";
          serviceConfig.Type = "oneshot";
          script = ''
            if zfs list -H -o name rpool/local/root@blank 2>/dev/null; then
              zfs rollback -r rpool/local/root@blank
            else
              echo "WARNING: snapshot rpool/local/root@blank not found, skipping rollback" >&2
            fi
          '';
        };
      };
    };

    fileSystems."/persist" = mkIf cfg.persist.enable {
      neededForBoot = true;
    };

    zramSwap = mkMerge [
      (mkIf cfg.swap.enable {
        enable = true;
      })
      (mkIf cfg.zfs.enable {
        writebackDevice =
          if cfg.zfs.tank.enable then "/dev/zvol/tank/local/swap" else "/dev/zvol/rpool/local/swap";
      })
    ];

    disko = {
      devices = {
        zpool =
          let
            dynamicDatasets = {
              "local/nix" = {
                type = "zfs_fs";
                mountpoint = "/nix";
              };
              "local/jellyfin" = mkIf config.services.jellyfin.enable {
                type = "zfs_fs";
                mountpoint = "/var/cache/jellyfin";
                options = {
                  atime = "off";
                  sync = "disabled";
                  recordsize = "1M";
                  primarycache = "metadata";
                  secondarycache = "none";
                };
              };
              "local/swap" = mkIf cfg.swap.enable {
                type = "zfs_volume";
                size = cfg.swap.size;
                options = {
                  volblocksize = "4096";
                  compression = "zle";
                  logbias = "throughput";
                  sync = "always";
                  primarycache = "metadata";
                  secondarycache = "none";
                };
              };

              "safe/home" = {
                type = "zfs_fs";
                mountpoint = "/home";
              };
              "safe/persist" = mkIf cfg.persist.enable {
                type = "zfs_fs";
                mountpoint = "/persist";
              };
              "safe/jellyfin" = mkIf config.services.jellyfin.enable {
                type = "zfs_fs";
                mountpoint = "/srv/jellyfin";
                options = {
                  recordsize = "1M";
                };
              };
              "safe/postgresql" = mkIf config.services.postgresql.enable {
                type = "zfs_fs";
                mountpoint = "/var/lib/postgresql";
                options = {
                  redundant_metadata = "most";
                  recordsize = "32k";
                  logbias = "throughput";
                };
              };
              "safe/nextcloud" = mkIf config.services.nextcloud.enable {
                type = "zfs_fs";
                mountpoint = "/var/lib/nextcloud";
                options = {
                  recordsize = "1M";
                };
              };
            };
          in
          mkIf cfg.zfs.enable {
            rpool = {
              type = "zpool";
              rootFsOptions = {
                encryption = "on";
                keyformat = "passphrase";
                keylocation = if cfg.zfs.key.enable then "file://${cfg.zfs.key.device}" else "prompt";
                mountpoint = "none";
                compression = "zstd";
                acltype = "posixacl";
                xattr = "sa";
                "com.sun:auto-snapshot" = "${toString (!cfg.zfs.tank.enable)}";
              };
              datasets = mkMerge [
                {
                  "local" = {
                    type = "zfs_fs";
                    options."com.sun:auto-snapshot" = "false";
                  };
                  "local/root" = {
                    type = "zfs_fs";
                    mountpoint = "/";
                    postCreateHook = optionalString cfg.persist.enable "zfs list -t snapshot -H -o name | grep -E '^rpool/local/root@blank$' || zfs snapshot rpool/local/root@blank";
                  };
                }
                (mkIf (!cfg.zfs.tank.enable) dynamicDatasets)
              ];
            };

            tank = mkIf cfg.zfs.tank.enable {
              type = "zpool";
              mode = {
                topology = {
                  type = "topology";
                  vdev = map (x: {
                    mode = "mirror";
                    members = x;
                  }) cfg.zfs.tank.mirrors;
                };
              };
              rootFsOptions = {
                encryption = "on";
                keyformat = "passphrase";
                keylocation = if cfg.zfs.key.enable then "file://${cfg.zfs.key.device}" else "prompt";
                mountpoint = "none";
                compression = "zstd";
                acltype = "posixacl";
                xattr = "sa";
                "com.sun:auto-snapshot" = "true";
              };
              datasets = mkMerge [
                {
                  "local" = {
                    type = "zfs_fs";
                    options."com.sun:auto-snapshot" = "false";
                  };
                }
                dynamicDatasets
              ];
            };
          };
      };
    };
  };
}

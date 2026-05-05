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
        };
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
        assertion = (lists.count (x: x) [ cfg.zfs.enable ]) == 1;
        message = "Only one filesystem can be configured";
      }
    ];

    boot = {
      loader = {
        efi.canTouchEfiVariables = true;
      };

      initrd.systemd.services = {
        "zfs-rollback" = mkIf (cfg.persist.enable && cfg.zfs.enable) {
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
    };

    fileSystems."/persist" = mkIf cfg.persist.enable {
      neededForBoot = true;
    };

    zramSwap =
      mkIf cfg.swap.enable {
        enable = true;
      }
      // (mkIf cfg.zfs.enable {
        writebackDevice =
          if cfg.zfs.tank.enable then "/dev/zvol/tank/local/swap" else "/dev/zvol/rpool/local/swap";
      });

    disko = {
      devices = {
        zpool = mkIf cfg.zfs.enable {
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
              "com.sun:auto-snapshot" = "${toString (!cfg.zfs.tank.enable)}";
            };
            datasets = {
              "local" = {
                type = "zfs_fs";
                options."com.sun:auto-snapshot" = "false";
              };
              "local/root" = {
                type = "zfs_fs";
                mountpoint = "/";
                postCreateHook = optionalString cfg.persist.enable "zfs list -t snapshot -H -o name | grep -E '^rpool/local/root@blank$' || zfs snapshot rpool/local/root@blank";
              };
              "local/nix" = mkIf (!cfg.zfs.tank.enable) {
                type = "zfs_fs";
                mountpoint = "/nix";
              };
              "local/swap" = mkIf (cfg.swap.enable && !cfg.zfs.tank.enable) {
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

              "safe/home" = mkIf (!cfg.zfs.tank.enable) {
                type = "zfs_fs";
                mountpoint = "/home";
              };
              "safe/persist" = mkIf (cfg.persist.enable && !cfg.zfs.tank.enable) {
                type = "zfs_fs";
                mountpoint = "/persist";
              };
            };
          };

          tank = mkIf cfg.zfs.tank.enable {
            type = "zpool";
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
            datasets = {
              "local" = {
                type = "zfs_fs";
                options."com.sun:auto-snapshot" = "false";
              };
              "local/nix" = {
                type = "zfs_fs";
                mountpoint = "/nix";
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

              "safe/home" = mkIf (!cfg.zfs.tank.enable) {
                type = "zfs_fs";
                mountpoint = "/home";
              };
              "safe/persist" = mkIf cfg.persist.enable {
                type = "zfs_fs";
                mountpoint = "/persist";
              };
            };
          };
        };
      };
    };
  };
}

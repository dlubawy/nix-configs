{
  lib,
  config,
  inputs,
  ...
}:
let
  inherit (lib) optionals mkIf mkMerge;
  hasPersist =
    (builtins.hasAttr "/persist" config.fileSystems && config.fileSystems."/persist".enable)
    || config.disko.persist.enable;
in
{
  imports = [
    inputs.preservation.nixosModules.preservation
  ];

  config =
    let
      etcDir = if config.system.etc.overlay.enable then "/.rw-etc/upper" else "/etc";
    in
    {
      assertions = [
        {
          assertion = config.preservation.enable -> (hasPersist);
          message = "Preservation requires persist mount in fileSystems";
        }
      ];

      users.users = mkMerge [
        (mkIf config.services.jellyfin.enable {
          "${config.services.jellyfin.user}" = {
            home = config.services.jellyfin.dataDir;
          };
        })
        (mkIf config.services.prometheus.enable {
          prometheus = {
            home = "/var/lib/${config.services.prometheus.stateDir}";
          };
        })
      ];

      systemd.tmpfiles.settings.preservation = mkMerge [
        (lib.mapAttrs' (
          username: opts:
          lib.nameValuePair (toString opts.home) {
            Z = {
              mode = opts.homeMode;
              user = opts.name;
              inherit (opts) group;
            };
          }
        ) (lib.filterAttrs (_username: opts: opts.enable && opts.home != "/var/empty") config.users.users))
        (mkIf config.services.jellyfin.enable {
          "${config.services.jellyfin.cacheDir}" = {
            Z = {
              user = config.services.jellyfin.user;
              group = config.services.jellyfin.group;
              mode = config.users.users."${config.services.jellyfin.user}".homeMode;
            };
          };
        })
        (mkIf config.services.postgresql.enable {
          "/var/lib/postgresql" = {
            Z = {
              user = config.users.users.postgres.name;
              group = config.users.users.postgres.group;
              mode = config.users.users.postgres.homeMode;
            };
          };
        })
      ];

      preservation = {
        preserveAt."/persist" = {
          directories = [
            "/var/lib/systemd/coredump"
            "/var/lib/systemd/rfkill"
            "/var/lib/systemd/timers"
            "/var/log"
            "/var/db"
          ]
          ++ (optionals config.boot.secure.enable [
            config.boot.lanzaboote.pkiBundle
          ])
          ++ (optionals (builtins.length (builtins.attrNames config.security.acme.certs) > 0) [
            {
              directory = "/var/lib/acme";
              group = config.security.acme.defaults.group;
              user = if config.security.acme.useRoot then "root" else "acme";
            }
          ])
          ++ (optionals config.services.tailscale.enable [
            "/var/lib/tailscale"
          ])
          ++ (optionals config.services.tsidp.enable [
            {
              directory = "/var/lib/private/tsidp";
              group = "nogroup";
              user = "nobody";
              parent.mode = "700";
            }
          ])
          ++ (optionals config.services.jellyfin.enable [
            {
              directory = config.services.jellyfin.dataDir;
              group = config.services.jellyfin.group;
              user = config.services.jellyfin.user;
              mode = config.users.users."${config.services.jellyfin.user}".homeMode;
            }
            {
              directory = config.services.jellyfin.cacheDir;
              group = config.services.jellyfin.group;
              user = config.services.jellyfin.user;
              mode = config.users.users."${config.services.jellyfin.user}".homeMode;
            }
          ])
          ++ (optionals config.services.grafana.enable [
            {
              directory = config.services.grafana.dataDir;
              group = "grafana";
              user = "grafana";
              mode = config.users.users.grafana.homeMode;
            }
          ])
          ++ (optionals config.services.prometheus.enable [
            {
              directory = "/var/lib/${config.services.prometheus.stateDir}";
              group = "prometheus";
              user = "prometheus";
              mode = config.users.users.prometheus.homeMode;
            }
          ])
          ++ (optionals config.services.loki.enable [
            {
              directory = config.services.loki.dataDir;
              group = config.services.loki.group;
              user = config.services.loki.user;
              mode = config.users.users."${config.services.loki.user}".homeMode;
            }
          ]);

          files = [
            {
              file = "${etcDir}/machine-id";
              inInitrd = true;
            }
            {
              file = "${etcDir}/ssh/ssh_host_rsa_key";
              how = "symlink";
              configureParent = true;
            }
            {
              file = "${etcDir}/ssh/ssh_host_ed25519_key";
              how = "symlink";
              configureParent = true;
            }
            {
              file = "/var/lib/systemd/random-seed";
              how = "symlink";
              inInitrd = true;
              configureParent = true;
            }
          ];
        };
      };
    };
}

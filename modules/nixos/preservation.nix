{
  lib,
  config,
  inputs,
  ...
}:
let
  inherit (lib) optionals mkIf;
  hasPersist =
    (builtins.hasAttr "/persist" config.fileSystems) && config.fileSystems."/persist".enable;
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

      systemd.tmpfiles.settings =
        let
          mkOwnership = dir: user: group: {
            "${dir}".Z = {
              user = user;
              group = group;
            };
          };
        in
        {
          grafana = mkIf config.services.grafana.enable (
            mkOwnership config.services.grafana.dataDir "grafana" "grafana"
          );
          jellyfin = mkIf config.services.jellyfin.enable (
            (mkOwnership config.services.jellyfin.dataDir config.services.jellyfin.user
              config.services.jellyfin.group
            )
            // (mkOwnership config.services.jellyfin.cacheDir config.services.jellyfin.user
              config.services.jellyfin.group
            )
          );
          nextcloud = mkIf config.services.nextcloud.enable (
            mkOwnership config.services.nextcloud.datadir "nextcloud" "nextcloud"
          );
          postgresql = mkIf config.services.postgresql.enable (
            mkOwnership "/var/lib/postgresql" "postgres" "postgres"
          );
          prometheus = mkIf config.services.prometheus.enable (
            mkOwnership "/var/lib/${config.services.prometheus.stateDir}" "prometheus" "prometheus"
          );
          loki = mkIf config.services.loki.enable (
            mkOwnership config.services.loki.dataDir config.services.loki.user config.services.loki.group
          );
        };

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
            }
            {
              directory = config.services.jellyfin.cacheDir;
              group = config.services.jellyfin.group;
              user = config.services.jellyfin.user;
            }
          ])
          ++ (optionals config.services.grafana.enable [
            {
              directory = config.services.grafana.dataDir;
              group = "grafana";
              user = "grafana";
            }
          ])
          ++ (optionals config.services.prometheus.enable [
            {
              directory = "/var/lib/${config.services.prometheus.stateDir}";
              group = "prometheus";
              user = "prometheus";
            }
          ])
          ++ (optionals config.services.loki.enable [
            {
              directory = config.services.loki.dataDir;
              group = config.services.loki.group;
              user = config.services.loki.user;
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

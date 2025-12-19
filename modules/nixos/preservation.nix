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
            mkOwnership config.services.jellyfin.dataDir config.services.jellyfin.user
              config.services.jellyfin.group
          );
          nextcloud = mkIf config.services.nextcloud.enable (
            mkOwnership config.services.nextcloud.datadir "nextcloud" "nextcloud"
          );
          postgresql = mkIf config.services.postgresql.enable (
            mkOwnership "/var/lib/postgresql" "postgres" "postgres"
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
          ++ (optionals config.services.jellyfin.enable [
            {
              directory = config.services.jellyfin.dataDir;
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

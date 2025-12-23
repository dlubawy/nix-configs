{
  pkgs,
  config,
  outputs,
  ...
}:
let
  topology = outputs.topology.${pkgs.stdenv.hostPlatform.system}.config;
  inherit (topology.lib.helpers) getAddress;
  cloudDomain = config.cloudDomain;
in
{
  age.secrets.nextcloud-exporter = {
    file = ../../secrets/nextcloud-exporter.age;
    owner = config.services.prometheus.exporters.nextcloud.user;
    group = config.services.prometheus.exporters.nextcloud.group;
  };

  services.prometheus = {
    enable = true;
    listenAddress = (getAddress "lil-nas" "enp5s0");
    exporters = {
      node = {
        enable = true;
        enabledCollectors = [
          "systemd"
        ];
        extraFlags = [ "--collector.textfile.directory=/var/run/prometheus-node-exporter" ];
      };
      nextcloud = {
        enable = true;
        url = "https://${cloudDomain}";
        tokenFile = config.age.secrets.nextcloud-exporter.path;
        extraFlags = [
          "--enable-info-apps"
          "--enable-info-update"
        ];
      };
      zfs.enable = true;
    };
    scrapeConfigs = [
      {
        job_name = "nas_metrics";
        static_configs = [
          {
            targets = [
              "${toString config.services.prometheus.exporters.node.listenAddress}:${toString config.services.prometheus.exporters.node.port}"
              "${toString config.services.prometheus.exporters.nextcloud.listenAddress}:${toString config.services.prometheus.exporters.nextcloud.port}"
              "${toString config.services.prometheus.exporters.zfs.listenAddress}:${toString config.services.prometheus.exporters.zfs.port}"
            ];
          }
        ];
      }
    ];
  };
}

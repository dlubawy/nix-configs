{
  pkgs,
  config,
  outputs,
  ...
}:
let
  topology = outputs.topology.${pkgs.stdenv.hostPlatform.system}.config;
  inherit (topology.lib.helpers) getAddress getPrometheusPort;
  lil-nas = (getAddress "lil-nas" "enp5s0");
  prometheusPort = (getPrometheusPort "lil-nas");
in
{
  services.prometheus = {
    enable = true;
    enableAgentMode = true;
    remoteWrite = [
      { url = "http://${lil-nas}:${prometheusPort}/api/v1/write"; }
    ];
    listenAddress = "127.0.0.1";
    exporters = {
      node = {
        enable = true;
        listenAddress = "127.0.0.1";
        enabledCollectors = [
          "systemd"
        ];
      };
    };
    scrapeConfigs = [
      {
        job_name = "pi_metrics";
        static_configs = [
          {
            targets = [
              "${toString config.services.prometheus.exporters.node.listenAddress}:${toString config.services.prometheus.exporters.node.port}"
            ];
          }
        ];
      }
    ];
  };
}

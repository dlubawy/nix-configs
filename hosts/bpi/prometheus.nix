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
  systemd = {
    timers = {
      prometheus-nf-conntrack = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnBootSec = "5m";
          OnCalendar = "*-*-* *:0/5:00";
          Unit = "prometheus-nf-conntrack.service";
        };
      };
      prometheus-iwinfo = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnBootSec = "5m";
          OnCalendar = "*-*-* *:*:00";
          Unit = "prometheus-iwinfo.service";
        };
      };
      prometheus-networkctl = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnBootSec = "5m";
          OnCalendar = "*-*-* *:0/5:00";
          Unit = "prometheus-networkctl.service";
        };
      };
    };
    services = {
      prometheus-nf-conntrack = {
        path = builtins.attrValues {
          inherit (pkgs)
            moreutils
            prometheus-nf-conntrack
            ;
        };
        script = ''
          ${pkgs.prometheus-nf-conntrack}/bin/main.py | ${pkgs.moreutils}/bin/sponge /var/run/prometheus-node-exporter/nf_conntrack.prom
        '';
        serviceConfig = {
          Type = "oneshot";
          User = "root";
        };
      };
      prometheus-iwinfo = {
        path = builtins.attrValues {
          inherit (pkgs)
            moreutils
            prometheus-iwinfo
            iwinfo-lite
            ;
        };
        script = ''
          ${pkgs.prometheus-iwinfo}/bin/main.py | ${pkgs.moreutils}/bin/sponge /var/run/prometheus-node-exporter/iwinfo.prom
        '';
        serviceConfig = {
          Type = "oneshot";
          User = "root";
        };
      };
      prometheus-networkctl = {
        path = builtins.attrValues {
          inherit (pkgs)
            moreutils
            prometheus-networkctl
            ;
        };
        script = ''
          ${pkgs.prometheus-networkctl}/bin/main.py | ${pkgs.moreutils}/bin/sponge /var/run/prometheus-node-exporter/networkctl.prom
        '';
        serviceConfig = {
          Type = "oneshot";
          User = "root";
        };
      };
    };
  };
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
          "ethtool"
          "systemd"
          "wifi"
        ];
        extraFlags = [ "--collector.textfile.directory=/var/run/prometheus-node-exporter" ];
      };
    };
    scrapeConfigs = [
      {
        job_name = "router_metrics";
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

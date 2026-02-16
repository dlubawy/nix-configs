{ pkgs, config, ... }:
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
    listenAddress = "192.168.1.1";
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
      {
        job_name = "loki_metrics";
        static_configs = [
          {
            targets = [
              "${toString config.services.loki.configuration.common.ring.instance_addr}:${toString config.services.loki.configuration.server.http_listen_port}"
              "${toString config.services.loki.configuration.common.ring.instance_addr}:${toString config.services.promtail.configuration.server.http_listen_port}"
            ];
          }
        ];
      }
    ];
  };
}

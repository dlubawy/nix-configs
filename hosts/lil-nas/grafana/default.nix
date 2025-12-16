{
  pkgs,
  config,
  outputs,
  ...
}:
let
  topology = outputs.topology.${pkgs.stdenv.hostPlatform.system}.config;
  inherit (topology.lib.helpers)
    getHomeDomain
    getAddress
    getLokiPort
    getPrometheusPort
    ;
  homeDomain = (getHomeDomain "bpi" "nginx");

  bpi = {
    address = (getAddress "bpi" "vl-lan");
    prometheusPort = (getPrometheusPort "bpi");
    lokiPort = (getLokiPort "bpi");
  };
in
{
  age = {
    secrets = {
      grafana-contact-points = {
        file = ../../../secrets/grafana-contact-points.age;
        owner = "grafana";
        group = "grafana";
      };
    };
  };

  services.grafana = {
    enable = true;
    openFirewall = true;
    settings = {
      analytics.reporting_enabled = false;
      server = {
        http_addr = "0.0.0.0";
        domain = "${homeDomain}";
        root_url = "https://%(domain)s/grafana/";
      };
    };
    provision = {
      enable = true;

      alerting = {
        contactPoints.path = config.age.secrets.grafana-contact-points.path;
        rules.path = "/etc/grafana/alerting.yaml";
        policies.settings.policies = [
          {
            orgId = 1;
            receiver = "Telegram";
            group_by = [
              "grafana_folder"
              "alertname"
            ];
          }
        ];
      };

      dashboards.settings.providers = [
        {
          name = "my dashboards";
          options.path = "/etc/grafana/dashboards";
        }
      ];

      datasources.settings.datasources = [
        {
          name = "bpi Prometheus";
          type = "prometheus";
          url = "http://${bpi.address}:${bpi.prometheusPort}";
          uid = "PBFA97CFB590B2093";
        }
        {
          name = "bpi Loki";
          type = "loki";
          url = "http://${bpi.address}:${bpi.lokiPort}";
          uid = "FECRLA1BDO9OGF";
          jsonData = {
            manageAlerts = false;
          };
        }
      ];
    };
  };
  environment.etc = {
    "grafana/dashboards/router.json" = {
      source = ./router.json;
      group = "grafana";
      user = "grafana";
    };
    "grafana/dashboards/dhcp_server.json" = {
      source = ./dhcp_server.json;
      group = "grafana";
      user = "grafana";
    };
    "grafana/dashboards/ssh.json" = {
      source = ./ssh.json;
      group = "grafana";
      user = "grafana";
    };
    "grafana/dashboards/promtail_monitoring.json" = {
      source = ./promtail_monitoring.json;
      group = "grafana";
      user = "grafana";
    };
    "grafana/dashboards/sudo_logs.json" = {
      source = ./sudo_logs.json;
      group = "grafana";
      user = "grafana";
    };
    "grafana/dashboards/firewall.json" = {
      source = ./firewall.json;
      group = "grafana";
      user = "grafana";
    };
    "grafana/alerting.yaml" = {
      source = ./alerting.yaml;
      group = "grafana";
      user = "grafana";
    };
  };
}

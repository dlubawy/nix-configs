{ config, vars, ... }:
{
  age = {
    secrets = {
      grafana-contact-points = {
        file = ../../../secrets/grafana-contact-points.age;
      };
    };
  };

  services.grafana = {
    enable = true;
    settings = {
      analytics.reporting_enabled = false;
      server = {
        http_port = 3001;
        domain = "${vars.homeDomain}";
        root_url = "https://%(domain)s/grafana/";
      };
    };
    provision = {
      enable = true;

      alerting = {
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
          name = "Prometheus";
          type = "prometheus";
          url = "http://${config.services.prometheus.listenAddress}:${toString config.services.prometheus.port}";
          uid = "PBFA97CFB590B2093";
        }
        {
          name = "Loki";
          type = "loki";
          url = "http://${toString config.services.loki.configuration.common.ring.instance_addr}:${toString config.services.loki.configuration.server.http_listen_port}";
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
    "grafana/alerting.yaml" = {
      source = ./alerting.yaml;
      group = "grafana";
      user = "grafana";
    };
    "grafana/contact_points.yaml" = {
      source = config.age.secrets.grafana-contact-points.path;
      group = "grafana";
      user = "grafana";
    };
  };
}

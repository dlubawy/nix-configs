{ config, ... }:
{
  services = {
    nginx = {
      enable = true;
      virtualHosts = {
        "grafana.home" = {
          listen = [
            {
              addr = "192.168.1.1";
              port = 80;
            }
          ];
          locations."/" = {
            proxyPass = "http://${toString config.services.grafana.settings.server.http_addr}:${toString config.services.grafana.settings.server.http_port}";
            proxyWebsockets = true;
            recommendedProxySettings = true;
          };
        };
      };
    };
    grafana = {
      enable = true;
      settings = {
        server = {
          http_port = 3001;
          domain = "grafana.home";
          root_url = "http://grafana.home";
        };
      };
      provision = {
        enable = true;

        dashboards.settings.providers = [
          {
            name = "my dashboards";
            options.path = "/etc/grafana-dashboards";
          }
        ];

        datasources.settings.datasources = [
          {
            name = "Prometheus";
            type = "prometheus";
            url = "http://${config.services.prometheus.listenAddress}:${toString config.services.prometheus.port}";
            uid = "PBFA97CFB590B2093";
          }
        ];
      };
    };
  };
  environment.etc = {
    "grafana-dashboards/router.json" = {
      source = ./router.json;
      group = "grafana";
      user = "grafana";
    };
    "grafana-dashboards/dhcp_server.json" = {
      source = ./dhcp_server.json;
      group = "grafana";
      user = "grafana";
    };
  };
}

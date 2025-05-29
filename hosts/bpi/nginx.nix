{
  lib,
  config,
  vars,
  ...
}:
let
  homeDomain = config.homeDomain;
in
{
  users.users.nginx.extraGroups = [ "acme" ];
  services.nginx = {
    enable = true;
    virtualHosts = {
      "adguard.home" = {
        listenAddresses = [
          "192.168.1.1"
        ];
        globalRedirect = "${homeDomain}/adguard";
      };

      "grafana.home" = {
        listenAddresses = [
          "192.168.1.1"
        ];
        globalRedirect = "${homeDomain}/grafana";
      };

      "${homeDomain}" = {
        forceSSL = true;
        useACMEHost = "${homeDomain}";
        listenAddresses = [
          "192.168.1.1"
        ];
        locations = {
          "/adguard/" = {
            proxyPass = "http://${toString config.services.adguardhome.host}:${toString config.services.adguardhome.port}/";
            extraConfig = ''
              proxy_cookie_path / /adguard/;
              proxy_redirect / /adguard/;
              proxy_set_header Host $host;
            '';
          };

          "/adguard/dns-query" = {
            proxyPass = "http://${toString config.services.adguardhome.host}:${toString config.services.adguardhome.port}/dns-query";
            extraConfig = ''
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_bind 192.168.1.1;
            '';
          };

          "/grafana/" = {
            proxyPass = "http://${toString config.services.grafana.settings.server.http_addr}:${toString config.services.grafana.settings.server.http_port}";
            recommendedProxySettings = true;
            extraConfig = ''
              rewrite ^/grafana/(.*)  /$1 break;
            '';
          };

          "/grafana/api/live/" = {
            proxyPass = "http://${toString config.services.grafana.settings.server.http_addr}:${toString config.services.grafana.settings.server.http_port}";
            proxyWebsockets = true;
            extraConfig = ''
              proxy_set_header Host $host;
              rewrite ^/grafana/(.*)  /$1 break;
            '';
          };
        };
      };
    };
  };
}

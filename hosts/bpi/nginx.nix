{
  pkgs,
  config,
  outputs,
  ...
}:
let
  homeDomain = config.homeDomain;
  topology = outputs.topology.${pkgs.stdenv.hostPlatform.system}.config;
  inherit (topology.lib.helpers) getAddress getJellyfinPort getGrafanaPort;

  lil-nas = {
    address = (getAddress "lil-nas" "enp5s0");
    grafanaPort = (getGrafanaPort "lil-nas");
    jellyfinPort = (getJellyfinPort "lil-nas");
  };
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

      "jellyfin.home" = {
        listenAddresses = [
          "192.168.1.1"
        ];
        globalRedirect = "${homeDomain}/jellyfin";
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
            proxyPass = "http://${lil-nas.address}:${lil-nas.grafanaPort}";
            recommendedProxySettings = true;
            extraConfig = ''
              rewrite ^/grafana/(.*)  /$1 break;
            '';
          };

          "/grafana/api/live/" = {
            proxyPass = "http://${lil-nas.address}:${lil-nas.grafanaPort}";
            proxyWebsockets = true;
            extraConfig = ''
              proxy_set_header Host $host;
              rewrite ^/grafana/(.*)  /$1 break;
            '';
          };

          "/jellyfin/" = {
            proxyPass = "http://${lil-nas.address}:${lil-nas.jellyfinPort}/";
            recommendedProxySettings = true;
            extraConfig = ''
              rewrite ^/jellyfin/(.*)  /$1 break;
              proxy_buffering off;
            '';
          };

          "/jellyfin/socket/" = {
            proxyPass = "http://${lil-nas.address}:${lil-nas.jellyfinPort}/socket/";
            proxyWebsockets = true;
            extraConfig = ''
              proxy_set_header Host $host;
              rewrite ^/jellyfin/(.*)  /$1 break;
            '';
          };
        };
      };
    };
  };
}

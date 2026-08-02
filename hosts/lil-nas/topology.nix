{
  pkgs,
  lib,
  config,
  outputs,
  ...
}:
let
  inherit (lib) mkForce;
  inherit (config.lib.topology) mkConnectionRev mkConnection;
  topology = outputs.topology.${pkgs.stdenv.hostPlatform.system}.config;
  inherit (topology.lib.helpers) getDomain;
  homeDomain = (getDomain "bpi" "adguardhome");
  address = "192.168.10.10";
in
{
  config = {
    topology = {
      enable = true;
      self = {
        hardware.info = "GMKtec G9";
        interfaces = {
          enp5s0 = {
            addresses = [ address ];
            mac = "e0:51:d8:1d:ba:d6";
            physicalConnections = [
              (mkConnectionRev "bpi" "sfp2")
            ];
          };
          tailscale0 = {
            addresses = [ "dhcp" ];
            virtual = true;
            physicalConnections = [ (mkConnection "tailscale" "lan") ];
          };
        };
        services = {
          jellyfin.info = "https://${homeDomain}/jellyfin";
          grafana.info = mkForce "https://${homeDomain}/grafana";
          collabora-online = {
            info = "https://${config.collaboraDomain}";
            icon = "services.collabora-online";
            name = "Collabora Online";
          };
          loki = {
            hidden = true;
            details = {
              listen = {
                text = "${toString config.services.loki.configuration.common.ring.instance_addr}:${toString config.services.loki.configuration.server.http_listen_port}";
              };
            };
          };
          prometheus.hidden = true;
        };
      };
    };
  };
}

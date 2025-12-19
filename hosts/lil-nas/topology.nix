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
  inherit (topology.lib.helpers) getHomeDomain;
  homeDomain = (getHomeDomain "bpi" "nginx");
  cloudDomain = config.cloudDomain;
in
{
  topology = {
    enable = true;
    self = {
      hardware.info = "GMKtec G9";
      interfaces = {
        enp5s0 = {
          addresses = [ "192.168.1.10" ];
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
        nginx.info = "${cloudDomain}";
        jellyfin.info = "${homeDomain}/jellyfin";
        grafana.info = mkForce "${homeDomain}/grafana";
      };
    };
  };
}

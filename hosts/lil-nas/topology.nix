{
  pkgs,
  config,
  outputs,
  ...
}:
let
  inherit (config.lib.topology) mkConnectionRev mkConnection;
  homeDomain =
    outputs.topology.${pkgs.stdenv.hostPlatform.system}.config.nodes.bpi.services.nginx.info;
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
        jellyfin.info = "${homeDomain}/jellyfin";
      };
    };
  };
}

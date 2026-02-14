{ config, ... }:
let
  inherit (config.lib.topology) mkConnectionRev;
in
{
  topology = {
    enable = true;
    self = {
      hardware.info = "Dell XPS 15";
      interfaces = {
        wlp2s0 = {
          icon = "interfaces.wifi";
          addresses = [ "dhcp" ];
          physicalConnections = [
            (mkConnectionRev "bpi" "wlan0.20")
            (mkConnectionRev "bpi" "wlan1.20")
          ];
        };
      };
    };
  };
}

{ config, ... }:
let
  inherit (config.lib.topology) mkConnectionRev;
in
{
  topology = {
    enable = true;
    self = {
      hardware.info = "GMKtec G9";
      interfaces = {
        "enp5s0" = {
          addresses = [ "192.168.1.10" ];
          mac = "e0:51:d8:1d:ba:d6";
          physicalConnections = [
            (mkConnectionRev "bpi" "lan1")
          ];
        };
      };
    };
  };
}

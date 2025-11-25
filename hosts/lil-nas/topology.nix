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
        lan1 = {
          addresses = [ "192.168.1.10" ];
          physicalConnections = [
            (mkConnectionRev "bpi" "lan1")
          ];
        };
      };
    };
  };
}

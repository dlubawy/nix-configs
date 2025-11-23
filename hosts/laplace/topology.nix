{ config, ... }:
let
  inherit (config.lib.topology) mkConnectionRev;
in
{
  topology = {
    enable = true;
    self = {
      info = "MacBook Pro M1";
      interfaceGroups = [
        [ "en0" ]
        [ "utun4" ]
      ];
      connections = {
        utun4 = mkConnectionRev "tailscale" "lan";
      };
      icon = "devices.laptop";
      deviceIcon = "devices.nix-darwin";
      interfaces = {
        en0 = {
          icon = "interfaces.wifi";
          addresses = [ "dhcp" ];
          physicalConnections = [
            (mkConnectionRev "bpi" "wlan0.20")
            (mkConnectionRev "bpi" "wlan1.20")
          ];
        };
        utun4 = {
          icon = "interfaces.tailscale";
          addresses = [ "dhcp" ];
          virtual = true;
        };
      };
    };
  };
}

{
  config,
  ...
}:
let
  inherit (config.lib.topology) mkConnectionRev mkConnection;
  homeAssistantDomain = config.homeAssistantDomain;
  address = "192.168.10.11";
in
{

  config = {
    topology = {
      enable = true;
      self = {
        hardware.info = "Raspberry Pi 3 Model B+";
        interfaces = {
          enu1u1 = {
            addresses = [ address ];
            mac = "b8:27:eb:63:a3:df";
            physicalConnections = [
              (mkConnectionRev "bpi" "lan1")
            ];
          };
          tailscale0 = {
            addresses = [ "dhcp" ];
            virtual = true;
            physicalConnections = [ (mkConnection "tailscale" "lan") ];
          };
        };
        services = {
          homeAssistant = {
            info = "https://${homeAssistantDomain}";
            icon = "services.home-assistant";
            name = "Home Assistant";
            details.listen.text = "${address}:8123";
          };
        };
      };
    };
  };
}

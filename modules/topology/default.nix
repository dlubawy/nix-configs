{
  config,
  outputs,
  ...
}:
with config.lib.topology;
{
  config = {
    nixosConfigurations = {
      bpi = outputs.nixosConfigurations.bpi;
    };

    icons = {
      interfaces = {
        tailscale.file = ./tailscale.png;
      };
      devices = {
        nix-darwin.file = ./nix-darwin.png;
      };
    };

    nodes = {
      laplace = mkDevice "laplace" {
        info = "MacBook Pro M1";
        interfaceGroups = [
          [ "en0" ]
          [ "utun4" ]
        ];
        connections = {
          en0 = mkConnectionRev "bpi" "wlan1.20";
          utun4 = mkConnectionRev "bpi" "tailscale0";
        };
        icon = "devices.laptop";
        deviceIcon = "devices.nix-darwin";
        interfaces = {
          en0 = {
            icon = "interfaces.wifi";
            addresses = [ "dhcp" ];
          };
          utun4 = {
            icon = "interfaces.tailscale";
            addresses = [ "dhcp" ];
            virtual = true;
          };
        };
      };
    };
  };
}

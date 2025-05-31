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

    networks = {
      tailscale = {
        name = "Tailscale Network";
        cidrv4 = "100.64.0.0/10";
      };
    };

    nodes = {
      tailscale = mkSwitch "Tailscale" {
        info = "Tailscale Switching Server";
        image = ./tailscale.png;
        interfaceGroups = [ [ "lan" ] ];
        interfaces.lan = {
          renderer.hidePhysicalConnections = true;
          network = "tailscale";
        };
      };
      laplace = mkDevice "laplace" {
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
  };
}

{
  lib,
  config,
  ...
}:
let
  inherit (config.lib.topology) mkDevice mkInternet mkConnection;
  homeDomain = config.homeDomain;
in
{
  topology = {
    enable = true;
    nodes = {
      internet = mkInternet {
        connections = mkConnection "bpi" "sfp2";
      };
      laptop = mkDevice "Laptop" {
        interfaceGroups = [ [ "wifi" ] ];
        interfaces.wifi = {
          addresses = [ "192.168.20.10" ];
          mac = "8c:3b:4a:a7:9d:89";
          physicalConnections = [
            (mkConnection "bpi" "wlan0.20")
            (mkConnection "bpi" "wlan1.20")
          ];
        };
        icon = "devices.laptop";
      };
      gamingPC = mkDevice "👾 Gaming PC" {
        interfaceGroups = [ [ "wifi" ] ];
        interfaces.wifi = {
          addresses = [ "192.168.20.11" ];
          mac = "08:b4:d2:6b:5e:0e";
          physicalConnections = [
            (mkConnection "bpi" "wlan0.20")
            (mkConnection "bpi" "wlan1.20")
          ];
        };
      };
      printer = mkDevice "🖨️ Printer" {
        interfaceGroups = [ [ "wifi" ] ];
        connections.wifi = mkConnection "bpi" "wlan0-1.30";
        interfaces.wifi = {
          addresses = [ "192.168.30.10" ];
          mac = "c8:d9:d2:e8:38:6a";
        };
      };
      tv = mkDevice "📺 TV" {
        interfaceGroups = [ [ "wifi" ] ];
        interfaces = {
          wifi = {
            addresses = [ "192.168.30.11" ];
            mac = "c2:08:44:c7:48:a9";
            physicalConnections = [
              (mkConnection "bpi" "wlan0.30")
              (mkConnection "bpi" "wlan1.30")
            ];
          };
          wifi2 = {
            addresses = [ "192.168.30.12" ];
            mac = "d8:e3:5e:52:16:9a";
            physicalConnections = [
              (mkConnection "bpi" "wlan0.30")
              (mkConnection "bpi" "wlan1.30")
            ];
          };
        };
      };
      iot = mkDevice "🤖 IoT Devices" {
        interfaceGroups = [ [ "wifi" ] ];
        connections.wifi = mkConnection "bpi" "wlan0-1.30";
        interfaces.wifi = {
          addresses = [ "dhcp" ];
        };
      };
      guests = mkDevice "⚠️ Guest Devices" {
        interfaceGroups = [ [ "wifi" ] ];
        interfaces.wifi = {
          addresses = [ "dhcp" ];
          physicalConnections = [
            (mkConnection "bpi" "wlan0.40")
            (mkConnection "bpi" "wlan1.40")
          ];
        };
      };
      phone = mkDevice "📱 Phone" {
        interfaceGroups = [
          [ "wifi" ]
          [ "vpn" ]
        ];
        connections.vpn = mkConnection "tailscale" "lan";
        interfaces.vpn = {
          virtual = true;
          addresses = [ "dhcp" ];
        };
        interfaces.wifi = {
          addresses = [ "dhcp" ];
          physicalConnections = [
            (mkConnection "bpi" "wlan0.20")
            (mkConnection "bpi" "wlan1.20")
          ];
        };
      };
    };

    networks = {
      lan = {
        name = "LAN Network";
        cidrv4 = "192.168.1.1/24";
      };
      user = {
        name = "User Network";
        cidrv4 = "192.168.20.1/24";
      };
      iot = {
        name = "IoT Network";
        cidrv4 = "192.168.30.1/24";
      };
      guest = {
        name = "Guest Network";
        cidrv4 = "192.168.40.1/24";
      };
    };

    self = {
      deviceType = lib.mkForce "router";
      hardware.info = "Banana Pi BPI-R3";

      interfaces = {
        sfp1 = { };
        lan1 = { };
        lan2 = { };
        lan3 = { };
        lan4 = { };

        "wlan0.20" = { };
        "wlan0.30" = { };
        "wlan0.40" = { };
        "wlan0-1.30" = { };
        "wlan1.20" = { };
        "wlan1.30" = { };
        "wlan1.40" = { };

        tailscale0 = {
          addresses = [ "dhcp" ];
          virtual = true;
          physicalConnections = [ (mkConnection "tailscale" "lan") ];
        };

        vl-lan = {
          network = "lan";
          sharesNetworkWith = [
            (x: lib.strings.hasSuffix ".99" x)
            (x: lib.strings.hasPrefix "lan" x)
            (x: x == "sfp1")
          ];
        };
        vl-user = {
          network = "user";
          sharesNetworkWith = [
            (x: lib.strings.hasSuffix ".20" x)
          ];
        };
        vl-iot = {
          network = "iot";
          sharesNetworkWith = [
            (x: lib.strings.hasSuffix ".30" x)
          ];
        };
        vl-guest = {
          network = "guest";
          sharesNetworkWith = [
            (x: lib.strings.hasSuffix ".40" x)
          ];
        };
      };
      services = {
        loki.hidden = true;
        prometheus.hidden = true;
        adguardhome.info = "${homeDomain}/adguard";
        grafana.info = lib.mkForce "${homeDomain}/grafana";
        nginx.info = "${homeDomain}";
      };
    };
  };
}

{
  lib,
  config,
  vars,
  ...
}:
with config.lib.topology;
{
  topology = {
    nodes = {
      internet = mkInternet {
        connections = mkConnection "bpi" "sfp2";
      };
      laptop = mkDevice "Laptop" {
        interfaceGroups = [ [ "wifi" ] ];
        interfaces.wifi = {
          addresses = [ "192.168.20.10" ];
          physicalConnections = [
            (mkConnection "bpi" "wlan0.20")
            (mkConnection "bpi" "wlan1.20")
          ];
        };
        icon = "devices.laptop";
      };
      printer = mkDevice "🖨️ Printer" {
        interfaceGroups = [ [ "wifi" ] ];
        connections.wifi = mkConnection "bpi" "wlan0-1.30";
        interfaces.wifi.addresses = [ "192.168.30.10" ];
      };
      tv = mkDevice "📺 TV" {
        interfaceGroups = [ [ "wifi" ] ];
        interfaces.wifi = {
          addresses = [ "192.168.30.11" ];
          physicalConnections = [
            (mkConnection "bpi" "wlan0.30")
            (mkConnection "bpi" "wlan1.30")
          ];
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
        adguardhome.info = "${vars.homeDomain}/adguard";
        grafana.info = lib.mkForce "${vars.homeDomain}/grafana";
        nginx.info = "${vars.homeDomain}";
      };
    };
  };
}

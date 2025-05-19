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
        connections.wifi = mkConnectionRev "bpi" "wlan1.20";
        interfaces.wifi.addresses = [ "192.168.20.10" ];
        icon = "devices.laptop";
      };
      printer = mkDevice "🖨️ Printer" {
        interfaceGroups = [ [ "wifi" ] ];
        connections.wifi = mkConnection "bpi" "wlan0-1.30";
        interfaces.wifi.addresses = [ "192.168.30.10" ];
      };
      tv = mkDevice "📺 TV" {
        interfaceGroups = [ [ "wifi" ] ];
        connections.wifi = mkConnection "bpi" "wlan1.30";
        interfaces.wifi.addresses = [ "192.168.30.11" ];
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
      tailscale = {
        name = "Tailscale Network";
        cidrv4 = "100.64.0.0/10";
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
        "wlan0.40" = { };
        "wlan0-1.30" = { };
        "wlan1.20" = { };
        "wlan1.30" = { };
        "wlan1.40" = { };

        tailscale0 = {
          network = "tailscale";
          addresses = [ "dhcp" ];
          virtual = true;
          icon = "interfaces.tailscale";
          renderer.hidePhysicalConnections = true;
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

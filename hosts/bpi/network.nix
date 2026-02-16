{
  lib,
  pkgs,
  config,
  outputs,
  ...
}:
let
  topology = outputs.topology.${pkgs.stdenv.hostPlatform.system}.config;
  inherit (topology.lib.helpers) getAddress getMac;
  getInterface = node: interface: {
    address = (getAddress node interface);
    mac = (getMac node interface);
  };
  gamingPC = (getInterface "gamingPC" "wifi");
  laptop = (getInterface "laptop" "wifi");
  printer = (getInterface "printer" "wifi");
  tv = (getInterface "tv" "wifi");
  tv2 = (getInterface "tv" "wifi2");
  lil-nas = (getInterface "lil-nas" "enp5s0");
  prometheusPort = (builtins.toString config.services.prometheus.port);
  lokiPort = (builtins.toString config.services.loki.configuration.server.http_listen_port);
in
{
  boot.kernel.sysctl."net.netfilter.nf_conntrack_acct" = true;
  environment.systemPackages = builtins.attrValues { inherit (pkgs) ldns; };
  networking = {
    enableIPv6 = true;
    dhcpcd.enable = false;
    nftables.enable = true;
    firewall = {
      enable = true;
      allowPing = false;
      checkReversePath = true;
      extraInputRules = lib.strings.concatLines [
        ################################################################
        # Drop
        ################################################################
        ''iifname { "br-wan" } counter drop comment "Drop all unsolicited traffic from WAN"''
        ################################################################
        # Accept
        ################################################################
        # vl-dmz
        ''ip saddr { ${lil-nas.address} } tcp dport { ${prometheusPort}, ${lokiPort} } accept comment "Allow grafana on NAS to access local prometheus and loki ports"''
      ];
      extraForwardRules = lib.strings.concatLines [
        ################################################################
        # Accept
        ################################################################
        # vl-lan
        ''iifname { "vl-lan" } oifname { "vl-lan", "vl-dmz", "vl-user", "vl-iot", "vl-guest" } accept comment "Allow all forwarding for management LAN"''
        # vl-user
        ''iifname { "vl-user" } ip daddr { 192.168.30.0/24 } accept comment "Allow trusted users to access IoT"''
        # vl-iot
        ''ip saddr { ${tv.address} } ip daddr { ${lil-nas.address} } tcp dport { 8096 } accept comment "Allow TV forward to NAS for Jellyfin"''
        ''ip saddr { ${tv.address} } ip daddr { ${lil-nas.address} } udp dport { 7359 } accept comment "Allow TV forward to NAS for Jellyfin"''
        ''ip saddr { ${tv.address} } ip daddr { ${gamingPC.address} } tcp dport { 27036, 27037 } accept comment "Allow TV forward to gaming PC for Steam Link"''
        ''ip saddr { ${tv.address} } ip daddr { ${gamingPC.address} } udp dport { 27031, 27036 } accept comment "Allow TV forward to gaming PC for Steam Link"''
        ''ip saddr { ${tv2.address} } ip daddr { 192.168.20.0/24, 192.168.40.0/24 } tcp sport { 7000 } accept comment "Allow TV forward to user and guest for AirPlay"''
        ''ip saddr { ${tv2.address} } ip daddr { 192.168.20.0/24, 192.168.40.0/24 } udp sport { 6002, 49152-65535 } accept comment "Allow TV forward to user and guest for AirPlay"''
        # vl-guest
        ''iifname { "vl-guest" } ip daddr { 192.168.30.10-192.168.30.20 } accept comment "Allow guests to access curated subnet"''
        # tailscale
        ''iifname { "${config.services.tailscale.interfaceName}" } oifname { "vl-dmz" } accept comment "Allow tailscale to access DMZ subnet"''
        ''iifname { "${config.services.tailscale.interfaceName}" } oifname { "vl-iot" } ip daddr { 192.168.30.10-192.168.30.20 } accept comment "Allow tailscale to access curated IoT subnet"''
        ################################################################
        # Reject
        ################################################################
        # vl-user
        ''iifname { "vl-user" } oifname { "vl-lan" } counter reject with icmp type net-prohibited comment "Reject user forwarding to management network"''
        # vl-iot
        ''iifname { "vl-iot" } oifname { "vl-lan", "vl-dmz", "vl-user", "vl-guest" } counter reject with icmp type net-prohibited comment "Reject IoT forwarding outside itself"''
        # vl-dmz, vl-guest, tailscale
        ''iifname { "vl-dmz", "vl-guest", "${config.services.tailscale.interfaceName}" } oifname { "vl-lan", "vl-dmz", "vl-user", "vl-iot", "vl-guest" } counter reject with icmp type net-prohibited comment "Reject DMZ, guest, and tailscale forwarding to all internal networks"''
      ];
      filterForward = true;
      trustedInterfaces = [ "vl-lan" ];
      interfaces = {
        "vl-dmz" = {
          allowedTCPPorts = [
            53
            853
            5355
          ];
          allowedUDPPorts = [
            53
            67
            853
            5353
            5355
            config.services.tailscale.relay.port
          ];
        };
        "vl-user" = {
          allowedTCPPorts = [
            53
            853
            5355
          ];
          allowedUDPPorts = [
            53
            67
            853
            5353
            5355
            config.services.tailscale.relay.port
          ];
        };
        "vl-iot" = {
          allowedTCPPorts = [
            53
            853
            5355
          ];
          allowedUDPPorts = [
            53
            67
            853
            5353
            5355
          ];
        };
        "vl-guest" = {
          allowedTCPPorts = [
            53
            853
            5355
          ];
          allowedUDPPorts = [
            53
            67
            853
            5353
            5355
          ];
        };
        "${config.services.tailscale.interfaceName}" = {
          allowedTCPPorts = [
            53
            80
            443
            853
          ];
          allowedUDPPorts = [
            53
            853
            config.services.tailscale.relay.port
          ];
        };
      };
    };
    nat = {
      enable = true;
      enableIPv6 = true;
      externalInterface = "br-wan";
      internalInterfaces = [
        "vl-lan"
        "vl-dmz"
        "vl-user"
        "vl-iot"
        "vl-guest"
        "${config.services.tailscale.interfaceName}"
      ];
    };
    useDHCP = false;
    useNetworkd = true;
  };
  systemd.network = {
    enable = true;
    wait-online.anyInterface = true;
    links = {
      "10-sfp1" = {
        matchConfig.OriginalName = "eth1";
        linkConfig = {
          Name = "sfp1";
          Description = "SFP 2.5 Gb WAN Port";
        };
      };
      "10-sfp2" = {
        matchConfig.OriginalName = "sfp2";
        linkConfig = {
          Description = "SFP 2.5 Gb LAN Port";
        };
      };
    };
    netdevs = {
      "20-br-lan" = {
        netdevConfig = {
          Kind = "bridge";
          Name = "br-lan";
        };
        bridgeConfig = {
          DefaultPVID = 0;
          VLANFiltering = true;
        };
      };
      "20-br-wan" = {
        netdevConfig = {
          Kind = "bridge";
          Name = "br-wan";
        };
      };
      "20-vl-lan" = {
        netdevConfig = {
          Description = "For management of the LAN/VLAN";
          Kind = "vlan";
          Name = "vl-lan";
        };
        vlanConfig.Id = 99;
      };
      "20-vl-dmz" = {
        netdevConfig = {
          Description = "For anything exposed to the Internet";
          Kind = "vlan";
          Name = "vl-dmz";
        };
        vlanConfig.Id = 10;
      };
      "20-vl-user" = {
        netdevConfig = {
          Description = "For PCs, laptops, phones (to isolate from IoT devices)";
          Kind = "vlan";
          Name = "vl-user";
        };
        vlanConfig.Id = 20;
      };
      "20-vl-iot" = {
        netdevConfig = {
          Description = "For Internet of Things (IoT) devices to protect other parts of your network";
          Kind = "vlan";
          Name = "vl-iot";
        };
        vlanConfig.Id = 30;
      };
      "20-vl-guest" = {
        netdevConfig = {
          Description = "Guest network for visitors/untrusted devices";
          Kind = "vlan";
          Name = "vl-guest";
        };
        vlanConfig.Id = 40;
      };
    };
    networks = {
      "30-sfp2" = {
        matchConfig.Name = "sfp2";
        bridge = [ "br-lan" ];
        bridgeVLANs = [
          {
            VLAN = 10;
            PVID = 10;
            EgressUntagged = 10;
          }
        ];
        networkConfig.ConfigureWithoutCarrier = true;
      };
      "30-lan" = {
        matchConfig.Name = "lan*";
        bridge = [ "br-lan" ];
        bridgeVLANs = [
          {
            VLAN = 99;
            PVID = 99;
            EgressUntagged = 99;
          }
        ];
        networkConfig.ConfigureWithoutCarrier = true;
      };
      "30-sfp1" = {
        matchConfig.Name = "sfp1";
        bridge = [ "br-wan" ];
        networkConfig.ConfigureWithoutCarrier = true;
      };
      "30-wan" = {
        matchConfig.Name = "wan";
        bridge = [ "br-wan" ];
        networkConfig.ConfigureWithoutCarrier = true;
      };
      "35-br-wan" = {
        matchConfig.Name = "br-wan";
        DHCP = "ipv4";
        networkConfig = {
          IPv6AcceptRA = true;
          IPv6PrivacyExtensions = false;
        };
        linkConfig.RequiredForOnline = "routable";
      };
      "35-br-lan" = {
        matchConfig.Name = "br-lan";
        vlan = [
          "vl-lan"
          "vl-dmz"
          "vl-user"
          "vl-iot"
          "vl-guest"
        ];
        bridgeVLANs = [
          { VLAN = 99; }
          { VLAN = 10; }
          { VLAN = 20; }
          { VLAN = 30; }
          { VLAN = 40; }
        ];
        networkConfig = {
          ConfigureWithoutCarrier = true;
          BindCarrier = [
            "sfp2"
            "lan1"
            "lan2"
            "lan3"
            "lan4"
          ]
          ++ (lib.attrNames config.services.hostapd.radios.wlan0.networks)
          ++ (lib.attrNames config.services.hostapd.radios.wlan1.networks);
        };
      };
      "35-vl-lan" = {
        matchConfig.Name = "vl-lan";
        address = [ "192.168.1.1/24" ];
        networkConfig = {
          DHCPServer = true;
          MulticastDNS = true;
          ConfigureWithoutCarrier = true;
        };
        dhcpServerConfig = {
          ServerAddress = "192.168.1.1/24";
          DefaultLeaseTimeSec = "12h";
          MaxLeaseTimeSec = "24h";
          DNS = "192.168.1.1";
          Router = "192.168.1.1";
          PoolOffset = 100;
          PoolSize = 100;
        };
      };
      "35-vl-dmz" = {
        matchConfig.Name = "vl-dmz";
        address = [ "192.168.10.1/24" ];
        networkConfig = {
          DHCPServer = true;
          MulticastDNS = true;
          ConfigureWithoutCarrier = true;
        };
        dhcpServerConfig = {
          ServerAddress = "192.168.10.1/24";
          DefaultLeaseTimeSec = "12h";
          MaxLeaseTimeSec = "24h";
          DNS = "192.168.1.1";
          Router = "192.168.10.1";
          PoolOffset = 100;
          PoolSize = 100;
        };
        dhcpServerStaticLeases = [
          {
            Address = lil-nas.address;
            MACAddress = lil-nas.mac;
          }
        ];
      };
      "35-vl-user" = {
        matchConfig.Name = "vl-user";
        address = [ "192.168.20.1/24" ];
        networkConfig = {
          DHCPServer = true;
          MulticastDNS = true;
          ConfigureWithoutCarrier = true;
        };
        dhcpServerConfig = {
          ServerAddress = "192.168.20.1/24";
          DefaultLeaseTimeSec = "12h";
          MaxLeaseTimeSec = "24h";
          DNS = "192.168.1.1";
          Router = "192.168.20.1";
          PoolOffset = 100;
          PoolSize = 100;
        };
        dhcpServerStaticLeases = [
          {
            Address = laptop.address;
            MACAddress = laptop.mac;
          }
          # Gaming PC
          {
            Address = gamingPC.address;
            MACAddress = gamingPC.mac;
          }
        ];
      };
      "35-vl-iot" = {
        matchConfig.Name = "vl-iot";
        address = [ "192.168.30.1/24" ];
        networkConfig = {
          DHCPServer = true;
          MulticastDNS = true;
          ConfigureWithoutCarrier = true;
        };
        dhcpServerConfig = {
          ServerAddress = "192.168.30.1/24";
          DefaultLeaseTimeSec = "12h";
          MaxLeaseTimeSec = "24h";
          DNS = "192.168.1.1";
          Router = "192.168.30.1";
          PoolOffset = 100;
          PoolSize = 100;
        };
        dhcpServerStaticLeases = [
          {
            Address = printer.address;
            MACAddress = printer.mac;
          }
          {
            Address = tv.address;
            MACAddress = tv.mac;
          }
          {
            Address = tv2.address;
            MACAddress = tv2.mac;
          }
        ];
      };
      "35-vl-guest" = {
        matchConfig.Name = "vl-guest";
        address = [ "192.168.40.1/24" ];
        networkConfig = {
          DHCPServer = true;
          MulticastDNS = true;
          ConfigureWithoutCarrier = true;
        };
        dhcpServerConfig = {
          ServerAddress = "192.168.40.1/24";
          DefaultLeaseTimeSec = "12h";
          MaxLeaseTimeSec = "24h";
          DNS = "192.168.1.1";
          Router = "192.168.40.1";
          PoolOffset = 100;
          PoolSize = 100;
        };
      };
    };
  };
  services = {
    avahi = {
      enable = true;
      allowInterfaces = [
        "vl-lan"
        "vl-dmz"
        "vl-user"
        "vl-iot"
        "vl-guest"
      ];
      reflector = true;
      openFirewall = false;
    };
  };
}

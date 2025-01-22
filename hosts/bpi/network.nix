{ lib, pkgs, ... }:
{
  boot.kernel.sysctl."net.netfilter.nf_conntrack_acct" = true;
  environment.systemPackages = with pkgs; [ ldns ];
  networking = {
    enableIPv6 = true;
    dhcpcd.enable = false;
    nftables.enable = true;
    firewall = {
      enable = true;
      allowPing = false;
      checkReversePath = true;
      extraInputRules = lib.strings.concatStringsSep "\n" [
        ''iifname { "br-wan" } counter drop comment "Drop all unsolicited traffic from WAN"''
        ''iifname { "vl-user", "vl-iot", "vl-guest" } ip daddr { 192.168.1.1 } tcp dport 53 accept comment "Allow DNS lookup from local networks"''
        ''iifname { "vl-user", "vl-iot", "vl-guest" } ip daddr { 192.168.1.1 } udp dport 53 accept comment "Allow DNS lookup from local networks"''
      ];
      extraForwardRules = lib.strings.concatStringsSep "\n" [
        ''iifname { "vl-user" } ip daddr { 192.168.30.0/24 } accept comment "Allow trusted users to access IoT"''
        ''iifname { "vl-guest" } ip daddr { 192.168.30.10-192.168.30.20 } accept comment "Allow guests to access curated subnet"''
        ''iifname { "vl-lan" } oifname { "vl-lan", "vl-user", "vl-iot", "vl-guest" } accept comment "Allow all forwarding for management LAN"''
        ''iifname { "vl-user" } oifname { "vl-lan" } counter reject with icmp type net-prohibited comment "Reject user forwarding to management network"''
        ''iifname { "vl-iot" } oifname { "vl-lan", "vl-user", "vl-guest" } counter reject with icmp type net-prohibited comment "Reject IoT forwarding outside itself"''
        ''iifname { "vl-guest" } oifname { "vl-lan", "vl-user", "vl-iot", "vl-guest" } counter reject with icmp type net-prohibited comment "Reject guest forwarding to all internal networks"''
      ];
      filterForward = true;
      trustedInterfaces = [ "vl-lan" ];
      interfaces = {
        "vl-lan" = {
          allowedTCPPorts = [ 53 ];
          allowedUDPPorts = [ 53 ];
        };
        "vl-user" = {
          allowedTCPPorts = [ 5355 ];
          allowedUDPPorts = [
            67
            5353
            5355
          ];
        };
        "vl-iot" = {
          allowedTCPPorts = [ 5355 ];
          allowedUDPPorts = [
            67
            5353
            5355
          ];
        };
        "vl-guest" = {
          allowedTCPPorts = [ 5355 ];
          allowedUDPPorts = [
            67
            5353
            5355
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
        "vl-user"
        "vl-iot"
        "vl-guest"
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
          Description = "SFP 2.5 Gb WAN Port";
          Name = "sfp1";
        };
      };
      "10-sfp2" = {
        matchConfig.OriginalName = "lan4";
        linkConfig = {
          Description = "SFP 2.5 Gb LAN Port";
          Name = "sfp2";
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
            VLAN = 99;
            PVID = 99;
            EgressUntagged = 99;
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
          "vl-user"
          "vl-iot"
          "vl-guest"
        ];
        bridgeVLANs = [
          { VLAN = 99; }
          { VLAN = 20; }
          { VLAN = 30; }
          { VLAN = 40; }
        ];
        networkConfig = {
          ConfigureWithoutCarrier = true;
          BindCarrier = [
            "sfp2"
            "lan0"
            "lan1"
            "lan2"
            "lan3"
          ];
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
            # printer
            Address = "192.168.30.10";
            MACAddress = "c8:d9:d2:e8:38:6a";
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
        "vl-user"
        "vl-iot"
        "vl-guest"
      ];
      reflector = true;
      openFirewall = false;
    };
  };
}

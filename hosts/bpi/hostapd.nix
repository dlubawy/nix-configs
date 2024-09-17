{
  lib,
  config,
  pkgs,
  ...
}:
{
  age = {
    secrets = {
      wifi-sae.file = ../../secrets/wifi-sae.age;
      wifi-iot-psk.file = ../../secrets/wifi-iot-psk.age;
    };
  };
  environment = {
    systemPackages = with pkgs; [
      hostap-wpa3
      iw
      iwinfo-lite
    ];
    etc."hostapd-wlan0.vlan".text = ''
      *  wlan0.#  br-lan
    '';
    etc."hostapd-wlan0-1.vlan".text = ''
      *  wlan0-1.#  br-lan
    '';
    etc."hostapd-wlan1.vlan".text = ''
      *  wlan1.#  br-lan
    '';
  };
  systemd.network = {
    networks = {
      "30-wl-lan" = {
        matchConfig = {
          Name = "*.99";
          Type = "wlan";
        };
        bridge = [ "br-lan" ];
        bridgeVLANs = [
          {
            bridgeVLANConfig = {
              VLAN = 99;
              PVID = 99;
              EgressUntagged = 99;
            };
          }
        ];
      };
      "30-wl-user" = {
        matchConfig = {
          Name = "*.20";
          Type = "wlan";
        };
        bridge = [ "br-lan" ];
        bridgeVLANs = [
          {
            bridgeVLANConfig = {
              VLAN = 20;
              PVID = 20;
              EgressUntagged = 20;
            };
          }
        ];
      };
      "30-wl-iot" = {
        matchConfig = {
          Name = "*.30";
          Type = "wlan";
        };
        bridge = [ "br-lan" ];
        bridgeVLANs = [
          {
            bridgeVLANConfig = {
              VLAN = 30;
              PVID = 30;
              EgressUntagged = 30;
            };
          }
        ];
      };
      "30-wl-guest" = {
        matchConfig = {
          Name = "*.40";
          Type = "wlan";
        };
        bridge = [ "br-lan" ];
        bridgeVLANs = [
          {
            bridgeVLANConfig = {
              VLAN = 40;
              PVID = 40;
              EgressUntagged = 40;
            };
          }
        ];
      };
    };
  };
  services.hostapd = {
    enable = true;
    radios = {
      wlan0 = {
        band = "2g";
        channel = 0;
        countryCode = "US";
        networks = {
          wlan0 = {
            apIsolate = true;
            authentication = {
              mode = "wpa3-sae";
              enableRecommendedPairwiseCiphers = true;
              saePasswordsFile = config.age.secrets.wifi-sae.path;
            };
            bssid = "9a:df:d2:a2:29:a0";
            settings = {
              bridge = "br-lan";
              dynamic_vlan = 2;
              vlan_file = "/etc/hostapd-wlan0.vlan";
              vlan_bridge = "br-vlan";
              multicast_to_unicast = 1;
            };
            ssid = "🎰 VivaLanVegas 🎰";
          };
          wlan0-1 = {
            apIsolate = true;
            authentication = {
              mode = "wpa2-sha1";
              wpaPskFile = config.age.secrets.wifi-iot-psk.path;
            };
            bssid = "92:df:d2:a2:29:a0";
            settings = {
              bridge = "br-lan";
              dynamic_vlan = 2;
              vlan_file = "/etc/hostapd-wlan0-1.vlan";
              vlan_bridge = "br-vlan";
              multicast_to_unicast = 1;
            };
            ssid = "🐰 conejitahouse 🐰";
          };
        };
        wifi4 = {
          enable = true;
          capabilities = [
            "HT40+"
            "LDPC"
            "SHORT-GI-20"
            "SHORT-GI-40"
            "TX-STBC"
            "RX-STBC1"
            "MAX-AMSDU-7935"
          ];
        };
      };
      wlan1 = {
        band = "5g";
        channel = 0;
        countryCode = "US";
        networks = {
          wlan1 = {
            apIsolate = true;
            authentication = {
              enableRecommendedPairwiseCiphers = true;
              saePasswordsFile = config.age.secrets.wifi-sae.path;
            };
            bssid = "da:ef:7a:02:e1:3c";
            settings = {
              bridge = "br-lan";
              dynamic_vlan = 2;
              vlan_file = "/etc/hostapd-wlan1.vlan";
              vlan_bridge = "br-vlan";
              multicast_to_unicast = 1;
            };
            ssid = "🎰 VivaLanVegas 🎰";
          };
        };
        wifi4 = {
          enable = true;
          capabilities = [
            "HT40+"
            "LDPC"
            "SHORT-GI-20"
            "SHORT-GI-40"
            "TX-STBC"
            "RX-STBC1"
            "MAX-AMSDU-7935"
          ];
        };
        wifi5 = {
          enable = true;
          capabilities = [
            "RXLDPC"
            "SHORT-GI-80"
            "SHORT-GI-160"
            "TX-STBC-2BY1"
            "SU-BEAMFORMER"
            "SU-BEAMFORMEE"
            "MU-BEAMFORMER"
            "MU-BEAMFORMEE"
            "RX-ANTENNA-PATTERN"
            "TX-ANTENNA-PATTERN"
            "RX-STBC-1"
            "SOUNDING-DIMENSION-4"
            "BF-ANTENNA-4"
            "VHT160"
            "MAX-MPDU-11454"
            "MAX-A-MPDU-LEN-EXP7"
          ];
          operatingChannelWidth = "160";
        };
        wifi6 = {
          enable = true;
          multiUserBeamformer = true;
          operatingChannelWidth = "160";
          singleUserBeamformee = true;
          singleUserBeamformer = true;
        };
      };
    };
  };
}

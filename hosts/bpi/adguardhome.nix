{
  lib,
  config,
  pkgs,
  ...
}:
let
  homeDomain = config.homeDomain;
in
{
  age = {
    secrets = {
      adguardhome = {
        file = ../../secrets/adguardhome.age;
        mode = "0444";
      };
    };
  };

  systemd.services.adguardhome = {
    preStart =
      let
        cfg = config.services.adguardhome;
        settingsFormat = pkgs.formats.yaml { };
        settings =
          if (cfg.settings != null) then
            cfg.settings
            // (
              if cfg.settings.schema_version < 23 then
                {
                  bind_host = cfg.host;
                  bind_port = cfg.port;
                }
              else
                { http.address = "${cfg.host}:${toString cfg.port}"; }
            )
          else
            null;
        configFile = (settingsFormat.generate "AdGuardHome.yaml" settings).overrideAttrs (_: {
          checkPhase = "${cfg.package}/bin/adguardhome -c $out --check-config";
        });
      in
      lib.mkForce (
        lib.optionalString (settings != null) ''
          if    [ -e "$STATE_DIRECTORY/AdGuardHome.yaml" ] \
             && [ "${toString cfg.mutableSettings}" = "1" ]; then
            # Writing directly to AdGuardHome.yaml results in empty file
            ${pkgs.yaml-merge}/bin/yaml-merge "$STATE_DIRECTORY/AdGuardHome.yaml" "${configFile}" "${config.age.secrets.adguardhome.path}" > "$STATE_DIRECTORY/AdGuardHome.yaml.tmp"
            mv "$STATE_DIRECTORY/AdGuardHome.yaml.tmp" "$STATE_DIRECTORY/AdGuardHome.yaml"
          else
            cp --force "${configFile}" "$STATE_DIRECTORY/AdGuardHome.yaml"
            chmod 600 "$STATE_DIRECTORY/AdGuardHome.yaml"
          fi
        ''
      );

    serviceConfig.LoadCredential =
      let
        certDir = config.security.acme.certs."${homeDomain}".directory;
      in
      [
        "cert.pem:${certDir}/cert.pem"
        "key.pem:${certDir}/key.pem"
      ];

    requires = [ "acme-${homeDomain}.service" ];
  };

  services.adguardhome = {
    enable = true;
    host = "127.0.0.1";
    port = 3000;
    settings = {
      users = [
        {
          name = "admin";
          password = "@adguardhome-password@";
        }
      ];
      tls =
        let
          credsDir = "/run/credentials/adguardhome.service";
        in
        {
          enabled = true;
          server_name = "${homeDomain}";
          force_https = false;
          allow_unencrypted_doh = true;
          port_https = 0;
          port_dns_over_tls = 853;
          port_dns_over_quic = 853;
          certificate_path = "${credsDir}/cert.pem";
          private_key_path = "${credsDir}/key.pem";
        };
      dns = {
        bind_hosts = [ "192.168.1.1" ];
        trusted_proxies = [
          "127.0.0.1"
          "192.168.1.1"
        ];
        upstream_dns = [
          "https://dns.quad9.net/dns-query"
          "tls://dns.quad9.net"
          "[/local/]127.0.0.53:53"
        ];
        upstream_mode = "parallel";
        fallback_dns = [
          "https://security.cloudflare-dns.com/dns-query"
          "tls://security.cloudflare-dns.com"
        ];
        bootstrap_dns = [
          "9.9.9.9"
          "149.112.112.112"
          "2620:fe::fe"
          "2620:fe::9"
        ];
        local_ptr_upstreams = [
          "127.0.0.53:53"
        ];
        enable_dnssec = true;
        ratelimit = 0;
      };
      filters = [
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_1.txt";
          name = "AdGuard DNS filter";
          id = 1;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_2.txt";
          name = "AdAway Default Blocklist";
          id = 2;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_7.txt";
          name = "Perflyst and Dandelion Sprout's Smart-TV Blocklist";
          id = 1723182134;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_44.txt";
          name = "HaGeZi's Threat Intelligence Feeds";
          id = 1723182136;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_59.txt";
          name = "AdGuard DNS Popup Hosts filter";
          id = 1755169304;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_27.txt";
          name = "OISD Blocklist Big";
          id = 1755169305;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_3.txt";
          name = "Peter Lowe's Blocklist";
          id = 1755169306;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_6.txt";
          name = "Dandelion Sprout's Game Console Adblock List";
          id = 1755169307;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_33.txt";
          name = "Steven Black's List";
          id = 1755169308;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_51.txt";
          name = "HaGeZi's Pro++ Blocklist";
          id = 1755169309;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_53.txt";
          name = "AWAvenue Ads Rule";
          id = 1755169310;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_4.txt";
          name = "Dan Pollock's List";
          id = 1755169311;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_39.txt";
          name = "Dandelion Sprout's Anti Push Notifications";
          id = 1755169312;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_30.txt";
          name = "Phishing URL Blocklist (PhishTank and OpenPhish)";
          id = 1755169313;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_45.txt";
          name = "HaGeZi's Allowlist Referral";
          id = 1755169314;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_54.txt";
          name = "HaGeZi's DynDNS Blocklist";
          id = 1755169315;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_12.txt";
          name = "Dandelion Sprout's Anti-Malware List";
          id = 1755169316;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_55.txt";
          name = "HaGeZi's Badware Hoster Blocklist";
          id = 1755169317;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_18.txt";
          name = "Phishing Army";
          id = 1755169318;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_8.txt";
          name = "NoCoin Filter List";
          id = 1755169319;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_31.txt";
          name = "Stalkerware Indicators List";
          id = 1755169320;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_50.txt";
          name = "uBlock₀ filters – Badware risks";
          id = 1755169321;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_42.txt";
          name = "ShadowWhisperer's Malware List";
          id = 1755169322;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_10.txt";
          name = "Scam Blocklist by DurableNapkin";
          id = 1755169323;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_9.txt";
          name = "The Big List of Hacked Malware Web Sites";
          id = 1755169324;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_11.txt";
          name = "Malicious URL Blocklist (URLHaus)";
          id = 1755169325;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_56.txt";
          name = "HaGeZi's The World's Most Abused TLDs";
          id = 1755169326;
        }

      ];
      whitelist_filters = [
        {
          enabled = true;
          url = "https://badblock.celenity.dev/abp/whitelist.txt";
          name = "BadBlock Whitelist";
          id = 1755169327;
        }
        {
          enabled = true;
          url = "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/whitelist-urlshortener.txt";
          name = "HaGeZi's URL Shorteners";
          id = 1755169328;
        }
      ];
      # NOTE: Commented as a record to archive initial list so we can allow user defined lists at runtime
      # without the list being overwritten on each restart of the server.
      # user_rules = [
      #   "||adservice.google.*^$important"
      #   "||adsterra.com^$important"
      #   "||amplitude.com^$important"
      #   "||analytics.edgekey.net^$important"
      #   "||analytics.twitter.com^$important"
      #   "||app.adjust.*^$important"
      #   "||app.*.adjust.com^$important"
      #   "||app.appsflyer.com^$important"
      #   "||doubleclick.net^$important"
      #   "||googleadservices.com^$important"
      #   "||guce.advertising.com^$important"
      #   "||metric.gstatic.com^$important"
      #   "||mmstat.com^$important"
      #   "||statcounter.com^$important"
      # ];
      filtering = {
        rewrites = [
          {
            domain = "${homeDomain}";
            answer = "192.168.1.1";
          }
          {
            domain = "adguard.home";
            answer = "192.168.1.1";
          }
          {
            domain = "grafana.home";
            answer = "192.168.1.1";
          }
        ];
      };
    };
  };
}

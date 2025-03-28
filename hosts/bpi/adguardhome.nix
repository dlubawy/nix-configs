{
  lib,
  config,
  pkgs,
  vars,
  ...
}:
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
        certDir = config.security.acme.certs."${vars.homeDomain}".directory;
      in
      [
        "cert.pem:${certDir}/cert.pem"
        "key.pem:${certDir}/key.pem"
      ];

    requires = [ "acme-finished-${vars.homeDomain}.target" ];
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
          server_name = "${vars.homeDomain}";
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
          "https://security.cloudflare-dns.com/dns-query"
          "https://dns.quad9.net/dns-query"
          "[/local/]127.0.0.53:53"
        ];
        fallback_dns = [
          "https://dns.google/dns-query"
        ];
        bootstrap_dns = [
          "8.8.8.8"
          "8.8.4.4"
          "2001:4860:4860::8888"
          "2001:4860:4860::8844"
        ];
        local_ptr_upstreams = [
          "127.0.0.53:53"
        ];
        enable_dnssec = true;
      };
      filters = [
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_1.txt";
          name = "AdGuard DNS filter";
          id = 1;
        }
        {
          enabled = false;
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
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_48.txt";
          name = "HaGeZi's Pro Blocklist";
          id = 1723182135;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_44.txt";
          name = "HaGeZi's Threat Intelligence Feeds";
          id = 1723182136;
        }
      ];
      filtering = {
        rewrites = [
          {
            domain = "${vars.homeDomain}";
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

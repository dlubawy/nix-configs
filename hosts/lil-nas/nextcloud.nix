{
  pkgs,
  config,
  vars,
  outputs,
  ...
}:
let
  topology = outputs.topology.${pkgs.stdenv.hostPlatform.system}.config;
  inherit (topology.lib.helpers) getAddress;
  cloudDomain = config.cloudDomain;
in
{
  age.secrets = {
    nextcloud.file = ../../secrets/nextcloud.age;
    cloudflare-dns-token.file = ../../secrets/cloudflare-dns-token.age;
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  services.nextcloud = {
    enable = true;
    settings = {
      loglevel = 1;
      log_type = "systemd";
      log_type_audit = "systemd";
      allow_local_remote_servers = true;
      user_oidc = {
        enrich_login_id_token_with_userinfo = true;
      };
      trusted_domains = [ "*.ts.net" ];
      trusted_proxies = [ "127.0.0.1" ];
      enabledPreviewProviders = [
        "OC\\Preview\\BMP"
        "OC\\Preview\\GIF"
        "OC\\Preview\\HEIC"
        "OC\\Preview\\JPEG"
        "OC\\Preview\\Krita"
        "OC\\Preview\\MP3"
        "OC\\Preview\\MarkDown"
        "OC\\Preview\\OpenDocument"
        "OC\\Preview\\PNG"
        "OC\\Preview\\TXT"
        "OC\\Preview\\WebP"
        "OC\\Preview\\XBitmap"
      ];
    };
    extraApps = {
      inherit (config.services.nextcloud.package.packages.apps)
        news
        contacts
        cookbook
        user_oidc
        ;
    };
    extraAppsEnable = true;
    database.createLocally = true;
    hostName = cloudDomain;
    https = true;
    maxUploadSize = "1G";
    config = {
      adminpassFile = config.age.secrets.nextcloud.path;
      dbtype = "pgsql";
    };
  };

  users.users.nginx.extraGroups = [ "acme" ];
  services.nginx.virtualHosts = {
    ${config.services.nextcloud.hostName} = {
      forceSSL = true;
      useACMEHost = "${cloudDomain}";
      listenAddresses = [ (getAddress "lil-nas" "enp5s0") ];
    };
    "nextcloud.ts.net" = {
      listen = [
        {
          addr = "127.0.0.1";
          port = 8080;
        }
        {
          addr = "127.0.0.1";
          port = 8443;
        }
      ];
      locations."/" = {
        proxyPass = "https://${config.services.nextcloud.hostName}";
        recommendedProxySettings = true;
      };
    };
  };

  security = {
    acme = {
      acceptTerms = true;
      defaults = {
        email = "${vars.admin.email}";
        dnsResolver = "1.1.1.1:53";
      };
      certs = {
        "${cloudDomain}" = {
          dnsProvider = "cloudflare";
          credentialFiles = {
            CLOUDFLARE_DNS_API_TOKEN_FILE = config.age.secrets.cloudflare-dns-token.path;
          };
        };
      };
    };
  };
}

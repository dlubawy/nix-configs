{ config, vars, ... }:
let
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
    extraApps = {
      inherit (config.services.nextcloud.package.packages.apps)
        news
        contacts
        cookbook
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
  services.nginx.virtualHosts.${config.services.nextcloud.hostName} = {
    forceSSL = true;
    useACMEHost = "${cloudDomain}";
    listenAddresses = [ "192.168.1.10" ];
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

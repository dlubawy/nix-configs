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
  collaboraDomain = config.collaboraDomain;
in
{
  age.secrets = {
    cloudflare-dns-token.file = ../../secrets/cloudflare-dns-token.age;
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  users.users.nginx.extraGroups = [ "acme" ];

  services.nginx.virtualHosts = {
    ${config.services.nextcloud.hostName} = {
      forceSSL = true;
      useACMEHost = "${cloudDomain}";
      listenAddresses = [ (getAddress "lil-nas" "enp5s0") ];
      locations = {
        "/exapps/" = {
          proxyPass = "http://127.0.0.1:8780/exapps/";
          recommendedProxySettings = true;
        };
        "/whiteboard/" = {
          proxyPass = "http://${config.services.nextcloud-whiteboard-server.settings.HOST}:${config.services.nextcloud-whiteboard-server.settings.PORT}";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_set_header Host $host;
            rewrite ^/whiteboard/(.*)  /$1 break;
          '';
        };
      };
    };
    "${config.services.collabora-online.settings.server_name}" = {
      forceSSL = true;
      useACMEHost = "${collaboraDomain}";
      listenAddresses = [ (getAddress "lil-nas" "enp5s0") ];
      locations."/" = {
        proxyPass = "http://[::1]:${toString config.services.collabora-online.port}";
        proxyWebsockets = true;
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
        "${collaboraDomain}" = {
          dnsProvider = "cloudflare";
          credentialFiles = {
            CLOUDFLARE_DNS_API_TOKEN_FILE = config.age.secrets.cloudflare-dns-token.path;
          };
        };
      };
    };
  };
}

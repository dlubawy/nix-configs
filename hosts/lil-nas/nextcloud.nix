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
    nextcloud.file = ../../secrets/nextcloud.age;
    nextcloud-whiteboard.file = ../../secrets/nextcloud-whiteboard.age;
    cloudflare-dns-token.file = ../../secrets/cloudflare-dns-token.age;
    nextcloud-harp-key.file = ../../secrets/nextcloud-harp-key.age;
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  # Podman configuration for AppAPI and HaRP
  virtualisation = {
    docker.enable = false;

    podman = {
      enable = true;
      dockerCompat = true; # Required for HaRP to communicate via docker.sock
      dockerSocket.enable = true;
      defaultNetwork.settings.dns_enabled = true; # Essential for ExApps DNS resolution
    };

    oci-containers = {
      backend = "podman";
      containers.harp = {
        image = "ghcr.io/nextcloud/nextcloud-appapi-harp:release";
        extraOptions = [ "--network=host" ];
        environment = {
          NC_INSTANCE_URL = "https://${cloudDomain}";
        };
        environmentFiles = [ config.age.secrets.nextcloud-harp-key.path ];
        # Mount Podman's Docker-compatible socket (enabled via dockerCompat = true)
        volumes = [ "/var/run/docker.sock:/var/run/docker.sock" ];
      };
    };
  };

  services = {
    nextcloud = {
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
          contacts
          cookbook
          cospend
          news
          richdocuments
          user_oidc
          whiteboard
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
    nextcloud-whiteboard-server = {
      enable = true;
      settings = {
        NEXTCLOUD_URL = "https://${cloudDomain}";
        HOST = "127.0.0.1";
        PORT = "3005";
      };
      secrets = [ config.age.secrets.nextcloud-whiteboard.path ];
    };
    collabora-online = {
      enable = true;
      settings = {
        ssl = {
          enable = false;
          termination = true;
        };

        # Listen on loopback interface only, and accept requests from ::1
        net = {
          listen = "loopback";
          post_allow.host = [ "::1" ];
        };

        # Restrict loading documents from WOPI Host nextcloud.example.com
        storage.wopi = {
          "@allow" = true;
          host = [ cloudDomain ];
        };

        # Set FQDN of server
        server_name = collaboraDomain;
      };
    };
  };

  users.users.nginx.extraGroups = [ "acme" ];
  services.nginx.virtualHosts = {
    ${config.services.nextcloud.hostName} = {
      forceSSL = true;
      useACMEHost = "${cloudDomain}";
      listenAddresses = [ (getAddress "lil-nas" "enp5s0") ];
      locations = {
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
      locations = {
        "/" = {
          proxyPass = "https://${config.services.nextcloud.hostName}";
          recommendedProxySettings = true;
        };
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

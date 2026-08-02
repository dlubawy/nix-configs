{ config, ... }:
let
  homeAssistantDomain = config.homeAssistantDomain;
in
{
  age.secrets = {
    cloudflare-tunnel-cert.file = ../../secrets/cloudflare-tunnel-cert.age;
    cloudflare-tunnel-credentials.file = ../../secrets/cloudflare-tunnel-credentials.age;
    home-assistant-key.file = ../../secrets/home-assistant-key.age;
  };

  services = {
    cloudflared = {
      enable = true;
      tunnels = {
        home = {
          certificateFile = config.age.secrets.cloudflare-tunnel-cert.path;
          credentialsFile = config.age.secrets.cloudflare-tunnel-credentials.path;
          default = "http_status:404";
          ingress = {
            "${homeAssistantDomain}" = "http://localhost:8123";
          };
        };
      };
    };
    matter-server.enable = true;
  };

  virtualisation.oci-containers = {
    backend = "podman";
    containers.homeassistant = {
      volumes = [
        "${config.age.secrets.home-assistant-key.path}:/SERVICE_ACCOUNT.json:ro"
        "home-assistant:/config"
        "/run/dbus:/run/dbus:ro"
      ];
      environment.TZ = "America/Los_Angeles";
      # Note: The image will not be updated on rebuilds, unless the version label changes
      image = "ghcr.io/home-assistant/home-assistant:stable";
      capabilities = {
        NET_ADMIN = true;
        NET_RAW = true;
      };
      extraOptions = [
        # Use the host network namespace for all sockets
        "--network=host"
      ];
    };
  };
}

{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkIf;
in
{
  systemd = {
    services = {
      jellyfin.environment.LIBVA_DRIVER_NAME = "iHD";
      jellyfin-taildrive = mkIf config.services.tailscale.enable {
        description = "Tailscale drive service";
        after = [ "tailscaled.service" ];
        wants = [ "tailscaled.service" ];
        wantedBy = [ "jellyfin.service" ];
        startLimitBurst = 10;
        startLimitIntervalSec = 300;
        serviceConfig = {
          User = "jellyfin";
          Group = "jellyfin";
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = "${config.services.tailscale.package}/bin/tailscale drive share jellyfin /srv/jellyfin";
          Restart = "on-failure";
          RestartSec = "30s";
          ProtectHome = true;
          ProtectSystem = true;
          NoNewPrivileges = true;
          ProtectKernelLogs = true;
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
        };
      };
    };
    tmpfiles.settings.jellyfin = {
      "/srv/jellyfin" = {
        Z = {
          user = config.services.jellyfin.user;
          group = config.services.jellyfin.group;
        };
      };
    };
  };
  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };
}

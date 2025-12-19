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
        after = [ "tailscale.service" ];
        serviceConfig = {
          User = "jellyfin";
          Group = "jellyfin";
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = "${config.services.tailscale.package}/bin/tailscale drive share jellyfin /srv/jellyfin";
        };
      };
    };
    tmpfiles.settings.jellyfin."/srv/jellyfin" = {
      Z = {
        mode = "755";
        user = config.services.jellyfin.user;
        group = config.services.jellyfin.group;
      };
    };
  };
  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };
}

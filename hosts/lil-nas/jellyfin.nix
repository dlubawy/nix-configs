{
  ...
}:
{
  systemd.services.jellyfin.environment.LIBVA_DRIVER_NAME = "iHD";
  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };
}

{
  ...
}:
{
  imports = [
    ./disko.nix
    ./hardware.nix
    ./topology.nix
    ../../users/default.nix
  ];

  networking.hostName = "lil-nas";
  home-manager.gui.enable = false;
  users.shadow.enable = true;

  time.timeZone = "America/Los_Angeles";
  i18n.defaultLocale = "en_US.UTF-8";

  services = {
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
      };
    };

    tailscale = {
      enable = false;
      # authKeyFile = config.age.secrets.tailscale.path;
      extraUpFlags = [
        "--advertise-tags=tag:server"
      ];
    };
  };
}

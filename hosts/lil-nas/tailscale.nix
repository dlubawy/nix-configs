{
  ...
}:
{
  services = {
    tailscale = {
      enable = true;
      bootstrap = {
        enable = false;
        tags = [
          "server"
          "nas"
        ];
      };
      ssh.enable = true;
    };

    tsidp = {
      enable = true;
      bootstrap.enable = false;
    };
  };
}

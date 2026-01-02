{
  ...
}:
{
  services = {
    tailscale = {
      enable = true;
      bootstrap = {
        enable = false;
        tag = "server";
      };
      ssh.enable = true;
    };

    tsidp = {
      enable = true;
      bootstrap.enable = false;
    };
  };
}

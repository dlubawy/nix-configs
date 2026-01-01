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
    };

    tsidp = {
      enable = true;
      bootstrap.enable = false;
    };
  };
}

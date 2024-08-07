let
  systems = {
    pi = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGoYQAIbCdU2DaZienCzSXq2k6zul1UdkRDSOJ7gS5B7";
  };
  # TODO: add the other yubikeys as backups and consider user agnostic approach
  yubiKeys = {
    yubikey_nano = "age1yubikey1yf5x3tavzxk0clctwq0w37ggxxw7ltj84yyrt8gljyprhhrgvp4sv0ya2x";
  };
  allYubiKeys = builtins.attrValues yubiKeys;
in
{
  "adguardhome.age" = {
    publicKeys = [ systems.pi ] ++ allYubiKeys;
    armor = true;
  };
}

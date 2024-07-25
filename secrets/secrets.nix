let
  systems = {
    pi = "age1hjvksnzra4fa9c23yp3utq3tyf35hl29xvrq920n994gk7ctyvlsn6zvaz";
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

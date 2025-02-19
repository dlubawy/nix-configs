let
  systems = {
    pi = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGoYQAIbCdU2DaZienCzSXq2k6zul1UdkRDSOJ7gS5B7";
    bpi = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHiqMYDcsnho0BDO1n1UXRRoBYt/4NfcaLhn4kSrgN1O";
  };
  yubiKeys = {
    yubikey = "age1yubikey1dzu5w3mhcfgqe7jqepaz8pv44ckgmujwdvp5vds3xqwlkqvg8e3q3a0d0v";
    nano = "age1yubikey1yf5x3tavzxk0clctwq0w37ggxxw7ltj84yyrt8gljyprhhrgvp4sv0ya2x";
    backup = "age1yubikey1vkn4gw425p6wk37enpd5zy2zrm60ekwgergqce6w9tsp3pdpzvcqtqtj6l";
  };
  allYubiKeys = builtins.attrValues yubiKeys;
in
{
  "adguardhome.age" = {
    publicKeys = [
      systems.pi
      systems.bpi
    ] ++ allYubiKeys;
    armor = true;
  };
  "wifi-sae.age" = {
    publicKeys = [ systems.bpi ] ++ allYubiKeys;
    armor = true;
  };
  "wifi-iot-psk.age" = {
    publicKeys = [ systems.bpi ] ++ allYubiKeys;
    armor = true;
  };
  "wifi-shared-secret.age" = {
    publicKeys = [ systems.bpi ] ++ allYubiKeys;
    armor = true;
  };
  "tailscale.age" = {
    publicKeys = [ systems.bpi ] ++ allYubiKeys;
    armor = true;
  };
  "grafana-contact-points.age" = {
    publicKeys = [ systems.bpi ] ++ allYubiKeys;
    armor = true;
  };
}

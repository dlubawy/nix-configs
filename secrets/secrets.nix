let
  systems = {
    pi = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGoYQAIbCdU2DaZienCzSXq2k6zul1UdkRDSOJ7gS5B7";
    bpi = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHiqMYDcsnho0BDO1n1UXRRoBYt/4NfcaLhn4kSrgN1O";
    lil-nas = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIm1TRgerO2eXA5e4+IXStaD0AS4GR4J3Y3+dzmJbNX0";
  };
  yubiKeys = {
    yubikey = "age1yubikey1dzu5w3mhcfgqe7jqepaz8pv44ckgmujwdvp5vds3xqwlkqvg8e3q3a0d0v";
    nano = "age1yubikey1yf5x3tavzxk0clctwq0w37ggxxw7ltj84yyrt8gljyprhhrgvp4sv0ya2x";
    backup = "age1yubikey1vkn4gw425p6wk37enpd5zy2zrm60ekwgergqce6w9tsp3pdpzvcqtqtj6l";
  };
  allYubiKeys = builtins.attrValues yubiKeys;

  mkSecret = systems: {
    publicKeys = systems ++ allYubiKeys;
    armor = true;
  };
in
{
  "adguardhome.age" = mkSecret [ systems.bpi ];
  "wifi-sae.age" = mkSecret [ systems.bpi ];
  "wifi-iot-psk.age" = mkSecret [ systems.bpi ];
  "wifi-shared-secret.age" = mkSecret [ systems.bpi ];
  "tailscale.age" = mkSecret [
    systems.bpi
    systems.lil-nas
  ];
  "grafana-contact-points.age" = mkSecret [ systems.lil-nas ];
  "cloudflare-dns-token.age" = mkSecret [
    systems.bpi
    systems.lil-nas
  ];
  "nextcloud.age" = mkSecret [ systems.lil-nas ];
  "nextcloud-exporter.age" = mkSecret [ systems.lil-nas ];
  "nextcloud-whiteboard.age" = mkSecret [ systems.lil-nas ];
  "nextcloud-harp-key.age" = mkSecret [ systems.lil-nas ];
}

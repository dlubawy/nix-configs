{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
let
  enableGUI = config.gui.enable;
  pinEntry = lib.getExe (
    if enableGUI then
      (if pkgs.stdenv.isDarwin then pkgs.pinentry_mac else pkgs.pinentry-qt)
    else
      pkgs.pinentry-tty
  );
in
{
  imports = [ inputs.agenix.homeManagerModules.default ];
  xdg.configFile."agenix/age-nano-identity.txt" = {
    enable = true;
    text = ''
      #         Slot: 1
      #         Name: CN=YubiKey PIV Attestation 82
      #    Recipient: age1yubikey1yf5x3tavzxk0clctwq0w37ggxxw7ltj84yyrt8gljyprhhrgvp4sv0ya2x
      AGE-PLUGIN-YUBIKEY-1NJ7M2QVZU6E4A4G56S3TP
    '';
  };
  xdg.configFile."agenix/age-yubikey-identity.txt" = {
    enable = true;
    text = ''
      #         Slot: 1
      #         Name: CN=YubiKey PIV Attestation 82
      #    Recipient: age1yubikey1dzu5w3mhcfgqe7jqepaz8pv44ckgmujwdvp5vds3xqwlkqvg8e3q3a0d0v
      AGE-PLUGIN-YUBIKEY-1K3A6VQVZ7SE02GCJAJD22
    '';
  };
  xdg.configFile."agenix/age-backup-identity.txt" = {
    enable = true;
    text = ''
      #         Slot: 1
      #         Name: CN=YubiKey PIV Attestation 82
      #    Recipient: age1yubikey1vkn4gw425p6wk37enpd5zy2zrm60ekwgergqce6w9tsp3pdpzvcqtqtj6l
      AGE-PLUGIN-YUBIKEY-1A9F6WQVZY3VX0LSLJXN6Y
    '';
  };
  age = {
    ageBin = "umask u=rx,g=,o= && LANG=C PINENTRY_PROGRAM=${pinEntry} PATH=$PATH:${pkgs.age-plugin-yubikey}/bin ${pkgs.rage}/bin/rage";
    secrets = { };
    identityPaths = [
      "${config.xdg.configFile."agenix/age-nano-identity.txt".path}"
      "${config.xdg.configFile."agenix/age-yubikey-identity.txt".path}"
      "${config.xdg.configFile."agenix/age-backup-identity.txt".path}"
    ];
  };
}

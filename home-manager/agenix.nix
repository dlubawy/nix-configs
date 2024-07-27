{
  lib,
  pkgs,
  config,
  inputs,
  enableGUI,
  ...
}:
let
  pinEntry = lib.getExe (
    if enableGUI then
      (if pkgs.stdenv.isDarwin then pkgs.pinentry_mac else pkgs.pinentry-qt)
    else
      pkgs.pinentry-tty
  );
in
{
  imports = [ inputs.agenix.homeManagerModules.default ];
  # TODO: Add my other backup yubikeys so they can be used too
  xdg.configFile."agenix/age-yubikey-identity.txt" = {
    enable = true;
    text = ''
      #         Slot: 1
      #         Name: CN=YubiKey PIV Attestation 82
      #    Recipient: age1yubikey1yf5x3tavzxk0clctwq0w37ggxxw7ltj84yyrt8gljyprhhrgvp4sv0ya2x
      AGE-PLUGIN-YUBIKEY-1NJ7M2QVZU6E4A4G56S3TP
    '';
  };
  age = {
    ageBin = "umask u=rx,g=,o= && LANG=C PINENTRY_PROGRAM=${pinEntry} PATH=$PATH:${pkgs.age-plugin-yubikey}/bin ${pkgs.rage}/bin/rage";
    secrets = { };
    identityPaths = [ "${config.xdg.configFile."agenix/age-yubikey-identity.txt".path}" ];
  };
}

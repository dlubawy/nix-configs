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
  age = {
    ageBin = "umask u=rx,g=,o= && LANG=C PINENTRY_PROGRAM=${pinEntry} PATH=$PATH:${pkgs.age-plugin-yubikey}/bin ${pkgs.rage}/bin/rage";
    secrets = { };
    # TODO: add this to the config; shouldn't matter if public
    identityPaths = [ "${config.home.homeDirectory}/.config/agenix/age-yubikey-identity.txt" ];
  };
}

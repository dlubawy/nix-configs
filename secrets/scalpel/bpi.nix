{
  lib,
  config,
  pkgs,
  prev,
  ...
}:
let
  radios = builtins.attrNames prev.config.services.hostapd.radios;
  preStart = prev.config.systemd.services.hostapd.preStart;
  scalpel = pkgs.writeShellScript "bpi-scalpel" ''
    set -euo pipefail
    secret=$(cat "${config.age.secrets.wifi-shared-secret.path}")
    ${lib.concatMapStringsSep "\n" (
      radio:
      ''${pkgs.gnused}/bin/sed -i "s#@wifi-shared-secret@#$secret#g" "/run/hostapd/${radio}.hostapd.conf"''
    ) radios}
  '';
in
{
  systemd.services.hostapd.preStart = lib.mkForce (
    lib.strings.concatStringsSep "\n" [
      preStart
      "${scalpel}"
    ]
  );
}

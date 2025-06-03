{ lib, pkgs, ... }:
{
  hardware.firmware = lib.mkBefore [
    (pkgs.stdenvNoCC.mkDerivation {
      name = "openwrt-mtk-firmware";
      src = pkgs.fetchFromGitHub {
        owner = "openwrt";
        repo = "mt76";
        rev = "ee693260c52191c9c4764915178ce3586e926428";
        hash = "sha256-r+WW3dqPV03sQ1JNJkaolXj4ebg7lGb1ZOwIe4BusHY=";
      };
      dontPatch = true;
      dontConfigure = true;
      dontBuild = true;
      dontFixup = true;
      installPhase = ''
        mkdir -p $out/lib/firmware/mediatek
        mv firmware/* $out/lib/firmware/mediatek/
      '';
    })
  ];
}

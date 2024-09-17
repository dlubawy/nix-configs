{ pkgs, ... }:

pkgs.stdenv.mkDerivation {
  pname = "iwinfo-lite";
  version = "0.1.0";

  src = pkgs.fetchFromGitHub {
    owner = "MinimSecure";
    repo = "iwinfo-lite";
    rev = "c3044fbbe525cca36e4f0fb9ce0f257710cc6834";
    hash = "sha256-YAT9EgBTXI1YwrAPFC8oHGcMOrckQ7UoTOjnuXVr73Y=";
  };

  buildInputs = with pkgs; [
    libnl
    pkg-config
  ];
  buildPhase = ''
    NIX_CFLAGS_COMPILE="$(pkg-config --cflags libnl-3.0) $NIX_CFLAGS_COMPILE"
    make BACKENDS=nl80211 LDFLAGS="-lnl-3 -lnl-genl-3" CFLAGS="$NIX_CFLAGS_COMPILE"
  '';
  installPhase = ''
    mkdir -p $out/bin $out/lib
    cp iwinfo $out/bin
    cp libiwinfo.so $out/lib
  '';
}

{ pkgs, ... }:

pkgs.stdenv.mkDerivation {
  pname = "hostap-wpa3";
  version = "0.1.0";

  src = pkgs.fetchFromGitHub {
    owner = "vanhoefm";
    repo = "hostap-wpa3";
    rev = "72e297507b896702e6635540f5b241ec5e02ed06";
    hash = "sha256-zveLNcZN7+L1iw3i9tq8fOgCh7VdMTg8B2PEoJ2fGwQ=";
  };

  meta.platforms = [ "aarch64-linux" ];

  buildInputs = with pkgs; [
    pkg-config
    libnl
    openssl
    dbus
  ];
  buildPhase = ''
    cd ./hostapd
    cp defconfig .config
    make sae_pk_gen
  '';
  installPhase = ''
    mkdir -p $out/bin
    cp sae_pk_gen $out/bin
  '';
}

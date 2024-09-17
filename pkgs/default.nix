# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
pkgs: {
  # example = pkgs.callPackage ./example { };
  iwinfo-lite = pkgs.callPackage ./iwinfo-lite { };
  hostap-wpa3 = pkgs.callPackage ./hostap-wpa3 { };
  prometheus-nf-conntrack = pkgs.callPackage ./prometheus-nf-conntrack { };
  prometheus-iwinfo = pkgs.callPackage ./prometheus-iwinfo { };
  prometheus-networkctl = pkgs.callPackage ./prometheus-networkctl { };
}

# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
system:
let
  allPackages = {
    aarch64-darwin = pkgs: {
      # example = pkgs.callPackage ./example { };
      fuse-t = pkgs.callPackage ./fuse-t { };
      nixos-passwd = pkgs.callPackage ./nixos-passwd { };
    };
    x86_64-darwin = pkgs: { };
    aarch64-linux = pkgs: {
      iwinfo-lite = pkgs.callPackage ./iwinfo-lite { };
      hostap-wpa3 = pkgs.callPackage ./hostap-wpa3 { };
      prometheus-nf-conntrack = pkgs.callPackage ./prometheus-nf-conntrack { };
      prometheus-iwinfo = pkgs.callPackage ./prometheus-iwinfo { };
      prometheus-networkctl = pkgs.callPackage ./prometheus-networkctl { };
      nixos-passwd = pkgs.callPackage ./nixos-passwd { };
    };
    x86_64-linux = pkgs: {
      nixos-passwd = pkgs.callPackage ./nixos-passwd { };
    };
  };
in
if builtins.hasAttr system allPackages then
  allPackages.${system}
else
  # TODO: make this cleaner
  pkgs:
  allPackages.aarch64-darwin pkgs
  // allPackages.x86_64-darwin pkgs
  // allPackages.aarch64-linux pkgs
  // allPackages.x86_64-linux pkgs

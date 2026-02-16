# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
system:
let
  allPackages = {
    aarch64-darwin = pkgs: {
      # example = pkgs.callPackage ./example { };
      fuse-t = pkgs.callPackage ./fuse-t { };
      nixos-password = pkgs.callPackage ./nixos-password { };
    };
    x86_64-darwin = pkgs: { };
    aarch64-linux = pkgs: {
      iwinfo-lite = pkgs.callPackage ./iwinfo-lite { };
      hostap-wpa3 = pkgs.callPackage ./hostap-wpa3 { };
      prometheus-nf-conntrack = pkgs.callPackage ./prometheus-nf-conntrack { };
      prometheus-iwinfo = pkgs.callPackage ./prometheus-iwinfo { };
      prometheus-networkctl = pkgs.callPackage ./prometheus-networkctl { };
      nixos-password = pkgs.callPackage ./nixos-password { };
    };
    x86_64-linux = pkgs: {
      nixos-password = pkgs.callPackage ./nixos-password { };
    };
  };
in
if builtins.hasAttr system allPackages then
  allPackages.${system}
else
  builtins.abort "Unsupported system '${system}' for pkgs. Supported systems: ${builtins.concatStringsSep ", " (builtins.attrNames allPackages)}"

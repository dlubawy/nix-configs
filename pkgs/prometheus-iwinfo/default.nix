{ pkgs, ... }:
let
  iwinfo-lite = pkgs.callPackage ../iwinfo-lite { };
in
pkgs.python3Packages.buildPythonApplication {
  pname = "prometheusIwinfo";
  version = "0.1.0";

  meta.platforms = [ "aarch64-linux" ];

  buildInputs = [ iwinfo-lite ];
  propagatedBuildInputs = with pkgs.python3Packages; [ prometheus-client ];

  src = ./.;
}

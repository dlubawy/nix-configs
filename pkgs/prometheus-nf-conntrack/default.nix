{ pkgs, ... }:
pkgs.python3Packages.buildPythonApplication {
  pname = "prometheusNfConntrack";
  version = "0.1.0";

  meta.platforms = [ "aarch64-linux" ];

  propagatedBuildInputs = with pkgs.python3Packages; [ prometheus-client ];

  src = ./.;
}

{ pkgs, ... }:
pkgs.python3Packages.buildPythonApplication {
  pname = "prometheusNfConntrack";
  version = "0.1.0";

  propagatedBuildInputs = with pkgs.python3Packages; [ prometheus-client ];

  src = ./.;
}

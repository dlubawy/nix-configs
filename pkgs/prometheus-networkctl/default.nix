{ pkgs, ... }:
pkgs.python3Packages.buildPythonApplication {
  pname = "prometheusNetworkctl";
  version = "0.1.0";

  propagatedBuildInputs = with pkgs.python3Packages; [ prometheus-client ];

  src = ./.;
}

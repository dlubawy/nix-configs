{ pkgs, ... }:
pkgs.python3Packages.buildPythonApplication {
  pname = "prometheusNetworkctl";
  version = "0.1.0";

  meta.platforms = [ "aarch64-linux" ];

  propagatedBuildInputs = with pkgs.python3Packages; [ prometheus-client ];

  pyproject = true;
  build-system = with pkgs.python3Packages; [ setuptools ];

  src = ./.;
}

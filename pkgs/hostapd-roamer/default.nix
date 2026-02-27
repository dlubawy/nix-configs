{ pkgs, lib, ... }:
pkgs.python3Packages.buildPythonApplication {
  pname = "hostapdRoamer";
  version = "0.1.0";

  meta = {
    license = [ lib.licenses.bsd3 ];
    platforms = [ "aarch64-linux" ];
  };

  pyproject = true;
  buildInputs = with pkgs.python3Packages; [
    setuptools
  ];

  src = builtins.path {
    path = ./.;
    name = "hostapd-roamer";
  };
}

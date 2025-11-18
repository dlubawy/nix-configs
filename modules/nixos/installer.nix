{
  pkgs,
  lib,
  inputs,
  modulesPath,
  ...
}:
let
  inherit (lib) mkForce;
in
{
  imports = [
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
    ./nix.nix
  ];

  nix.gc.automatic = mkForce false;

  environment.systemPackages = [
    inputs.disko.packages.${pkgs.system}.disko
    inputs.disko.packages.${pkgs.system}.disko-install
  ];
}

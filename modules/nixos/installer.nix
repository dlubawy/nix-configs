{
  pkgs,
  inputs,
  outputs,
  vars,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
    ./nix.nix
  ];

  environment.systemPackages = [
    inputs.disko.packages.${pkgs.system}.disko
    inputs.disko.packages.${pkgs.system}.disko-install
  ];
}

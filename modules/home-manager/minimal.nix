{ lib, modulesPath, ... }:
let
  inherit (lib) mkEnableOption;
in
{
  imports = [
    "${modulesPath}/programs/btop.nix"
    "${modulesPath}/programs/direnv.nix"
    "${modulesPath}/programs/eza.nix"
    "${modulesPath}/programs/fd.nix"
    "${modulesPath}/programs/firefox"
    "${modulesPath}/programs/fish.nix"
    "${modulesPath}/programs/fzf.nix"
    "${modulesPath}/programs/man"
    "${modulesPath}/programs/ripgrep.nix"
    "${modulesPath}/programs/zoxide.nix"
    "${modulesPath}/services/nix-gc.nix"
  ];
  options = {
    minimal = mkEnableOption "Enable a minimal home configuration";
  };
}

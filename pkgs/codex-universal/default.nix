{ pkgs, nixpkgs, ... }:
let
  inherit (pkgs) symlinkJoin;
  inherit (import ./codex-universal.nix { inherit pkgs nixpkgs; }) codex-log codex-enter codex-start;
in
symlinkJoin {
  name = "codex-universal";
  paths = [
    codex-log
    codex-enter
    codex-start
  ];
}

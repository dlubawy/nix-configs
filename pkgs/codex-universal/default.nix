{ pkgs, containerPkgs, ... }:
let
  inherit (pkgs) symlinkJoin;
  inherit (import ./codex-universal.nix { inherit pkgs containerPkgs; })
    codex-log
    codex-enter
    codex-start
    ;
in
symlinkJoin {
  name = "codex-universal";
  paths = with pkgs; [
    codex-log
    codex-enter
    codex-start
    podman
  ];
}

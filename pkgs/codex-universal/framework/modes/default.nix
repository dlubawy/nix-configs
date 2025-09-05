{ pkgs, ... }:
let
  inherit (pkgs) lib;
  modes = [
    ./MODE_Brainstorming.md
    ./MODE_Introspection.md
    ./MODE_Orchestration.md
    ./MODE_Business_Panel.md
    ./MODE_Task_Management.md
    ./MODE_Token_Efficiency.md
  ];
in
lib.strings.concatLines (lib.lists.forEach modes (mode: builtins.readFile mode))

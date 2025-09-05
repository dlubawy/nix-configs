{ pkgs, ... }:
let
  inherit (pkgs) lib;
  cores = [
    ./BUSINESS_PANEL_EXAMPLES.md
    ./BUSINESS_SYMBOLS.md
    ./FLAGS.md
    ./PRINCIPLES.md
    ./RULES.md
  ];
in
lib.strings.concatLines (lib.lists.forEach cores (core: builtins.readFile core))

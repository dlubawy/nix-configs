{ pkgs, ... }:
let
  inherit (pkgs) lib;
  mcps = [
    ./MCP_Context7.md
    ./MCP_Magic.md
    ./MCP_Morphllm.md
    ./MCP_Playwright.md
    ./MCP_Sequential.md
    ./MCP_Serena.md
  ];
in
lib.strings.concatLines (lib.lists.forEach mcps (mcp: builtins.readFile mcp))

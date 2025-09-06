{ pkgs, codexHome, ... }:
let
  inherit (pkgs) lib writeTextFile;
  commands = [
    ./analyze.md
    ./brainstorm.md
    ./build.md
    ./business-panel.md
    ./cleanup.md
    ./design.md
    ./document.md
    ./estimate.md
    ./explain.md
    ./git.md
    ./help.md
    ./implement.md
    ./improve.md
    ./index.md
    ./load.md
    ./reflect.md
    ./save.md
    ./select-tool.md
    ./spawn.md
    ./task.md
    ./test.md
    ./troubleshoot.md
    ./workflow.md
  ];
in
(lib.lists.concatMap (command: [
  (writeTextFile rec {
    name = builtins.baseNameOf command;
    text = builtins.readFile command;
    destination = "${codexHome}/commands/${name}";
  })
]) commands)

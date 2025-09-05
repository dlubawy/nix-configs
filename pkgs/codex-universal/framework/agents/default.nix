{ pkgs, codexHome, ... }:
let
  inherit (pkgs) lib writeTextFile;
  agents = [
    ./python-expert.md
    ./learning-guide.md
    ./socratic-mentor.md
    ./devops-architect.md
    ./quality-engineer.md
    ./system-architect.md
    ./technical-writer.md
    ./backend-architect.md
    ./security-engineer.md
    ./frontend-architect.md
    ./refactoring-expert.md
    ./root-cause-analyst.md
    ./performance-engineer.md
    ./requirements-analyst.md
    ./business-panel-experts.md
  ];
in
(lib.lists.concatMap (agent: [
  (writeTextFile rec {
    name = builtins.baseNameOf agent;
    text = builtins.readFile agent;
    destination = "${codexHome}/agents/${name}";
  })
]) agents)

{ pkgs, ... }:
let
  gitBin = "${pkgs.git}/bin/git";
  awkBin = "${pkgs.gawk}/bin/awk";
in
{
  home.packages = with pkgs; [
    (writeScriptBin "git_prune_orphans" ''
      #!/usr/bin/env bash
      ${gitBin} fetch -p
      read -a remotes -r < <(${gitBin} branch -r | ${awkBin} -F'/' '{$1=""; gsub(/ /, "/", $0); print substr($0, 2)}' | tr '\n' ' ')
      read -a branches -r < <(${gitBin} branch --format "%(refname:short)" | tr '\n' ' ')
      read -a orphans -r < <(echo "''${remotes[@]}" "''${branches[@]}" | tr ' ' '\n' | sort | uniq -u | tr '\n' ' ')
      for orphan in "''${orphans[@]}"; do
        if [[ "$orphan" == "develop" ]] || [[ "$orphan" == "main" ]]; then
          continue
        fi
        read -p "Delete branch $orphan [y/N]: " -r confirm_deletion
        case "$confirm_deletion" in
          y|Y) echo "Deleting $orphan"; ${gitBin} branch -D "$orphan";;
          *) ;;
        esac
      done
    '')
  ];
}

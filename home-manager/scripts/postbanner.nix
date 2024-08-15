{ pkgs, ... }:
{
  home.packages = with pkgs; [
    lolcat
    toilet
    ansi2html
    (writeScriptBin "postbanner" ''
      #!/usr/bin/env bash

      NAME="postbanner"
      VERSION="0.027"
      AUTHOR="budRich"
      CONTACT='robstenklippa@gmail.com'
      CREATED="2017-09-30"
      UPDATED="2018-04-11"

      main(){
        while getopts :vhl:t:o: option
        do
          case "''${option}" in
            v) printf '%s\n' \
                 "$NAME - version: $VERSION" \
                 "updated: $UPDATED by $AUTHOR"
               exit ;;
            l) LOLCAT_OPTIONS="''${OPTARG}";;
            t) TOILET_OPTIONS=(''${OPTARG});;
            o) HTML_OUTPUT_FILE="''${OPTARG}";;
            h|*) printinfo && exit ;;
          esac
        done

        shift $((OPTIND-1))

        [[ -z $1 ]] && printinfo && exit

        TEXT="''${1//' '/'™'}"

        for w in ''${TEXT//'_'/' '}; do
          op+="$(echo ''${w//'™'/'  '} | ${pkgs.toilet}/bin/toilet -w 170 ''${TOILET_OPTIONS[@]})\n\n"
        done

        if [[ -n $HTML_OUTPUT_FILE ]]; then
          echo '<pre class="lolban">' > ''${HTML_OUTPUT_FILE}
          printf "''${op}" | ${pkgs.lolcat}/bin/lolcat -f ''${LOLCAT_OPTIONS} \
            | ${pkgs.ansi2html}/bin/ansi2html >> ''${HTML_OUTPUT_FILE}
          echo '</pre>' >> ''${HTML_OUTPUT_FILE}
        else
          printf "''${op}" | ${pkgs.lolcat}/bin/lolcat -f ''${LOLCAT_OPTIONS}
        fi
      }

      printinfo(){
        case "$1" in
          m ) printf '%s' "''${about}" ;;

          f )
            printf '%s' "''${bouthead}"
            printf '%s' "''${about}"
            printf '%s' "''${boutfoot}"
          ;;

          '''|* )
            printf '%s' "''${about}" | awk '
               BEGIN{ind=0}
               $0~/^```/{
                 if(ind!="1"){ind="1"}
                 else{ind="0"}
                 print ""
               }
               $0!~/^```/{
                 gsub("[`*]","",$0)
                 if(ind=="1"){$0="   " $0}
                 print $0
               }
             '
          ;;
        esac
      }

      bouthead="
      ''${NAME^^} 1 ''${CREATED} Linux \"User Manuals\"
      =======================================

      NAME
      ----
      "

      boutfoot="
      AUTHOR
      ------

      ''${AUTHOR} <''${CONTACT}>
      <https://budrich.github.io>

      SEE ALSO
      --------

      toilet(1)
      "

      about='
      `postbanner` - Creates a colorful ASCII banner in html

      SYNOPSIS
      --------

      `postbanner` [`-v`|`-h`] [`-o` *output-file*] [`-l` *lolcat-options*] [`-t` *toilet-options*] *TEXT*

      DESCRIPTION
      -----------

      `postbanner` creates *output-file* containing a multicolored
      ASCII text banner inside a `<div>` block generated from the
      *TEXT* string. '"'"'_'"'"' in string creates a linebreak in
      the banner.

      OPTIONS
      -------

      `-v`
        Show version and exit.

      `-h`
        Show help and exit.

      `-o` *HTML_OUTPUT_FILE*
        If not set output is send to `stdout`

      `-l` *LOLCAT_OPTIONS*
        `lolcat` options

      `-t` *TOILET_OPTIONS*
        `toilet` options


      DEPENDENCIES
      ------------

      lolcat
      toilet
      ansi2html

      EXAMPLES
      --------
      `postbanner -t '"'"'-f 3d.flf'"'"' -l '"'"'-p 10'"'"' -o "~/banner.html" "I <3_NY"`
      '

      if [ "$1" = "md" ]; then
        printinfo m
        exit
      elif [ "$1" = "man" ]; then
        printinfo f
        exit
      else
        main "''${@}"
      fi
    '')
  ];
}

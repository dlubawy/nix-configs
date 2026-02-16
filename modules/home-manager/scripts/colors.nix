{ pkgs, ... }:
let
  inherit (pkgs) writeScriptBin;
in
{
  home.packages = [
    (writeScriptBin "c-256" ''
      #!/usr/bin/env bash
      for i in {0..255}; do printf "\x1b[38;5;''${i}mcolor%-5i\x1b[0m" $i ; if ! (( ($i + 1 ) % 8 )); then echo ; fi ; done
    '')
    (writeScriptBin "c-abcdef" ''
      #!/bin/sh
      #
      # Autor: Ivo
      # ANSI Color -- use these variables to easily have different color
      #    and format output. Make sure to output the reset sequence after
      #    colors (f = foreground, b = background), and use the 'off'
      #    feature for anything you turn on.
      #

      initializeANSI()
      {
        esc=""

        blackf="''${esc}[30m";   redf="''${esc}[31m";    greenf="''${esc}[32m"
        yellowf="''${esc}[33m"   bluef="''${esc}[34m";   purplef="''${esc}[35m"
        cyanf="''${esc}[36m";    whitef="''${esc}[37m"   whitef="''${esc}[37m"

        blackb="''${esc}[40m";   redb="''${esc}[41m";    greenb="''${esc}[42m"
        yellowb="''${esc}[43m"   blueb="''${esc}[44m";   purpleb="''${esc}[45m"
        cyanb="''${esc}[46m";    whiteb="''${esc}[47m"

        boldon="''${esc}[1m";    boldoff="''${esc}[22m"
        italicson="''${esc}[3m"; italicsoff="''${esc}[23m"
        ulon="''${esc}[4m";      uloff="''${esc}[24m"
        invon="''${esc}[7m";     invoff="''${esc}[27m"

        reset="''${esc}[0m"
      }

      # note in this first use that switching colors doesn't require a reset
      # first - the new color overrides the old one.

      initializeANSI

      cat << EOF

      ''${boldon}''${redf}   ██████  ''${reset} ''${boldon}''${greenf}██████   ''${reset}''${boldon}''${yellowf}  ██████''${reset} ''${boldon}''${bluef}██████  ''${reset} ''${boldon}''${purplef}  ██████''${reset} ''${boldon}''${cyanf}  ███████''${reset}
      ''${boldon}''${redf}   ████████''${reset} ''${boldon}''${greenf}██    ██ ''${reset}''${boldon}''${yellowf}██      ''${reset} ''${boldon}''${bluef}██    ██''${reset} ''${boldon}''${purplef}██████  ''${reset} ''${boldon}''${cyanf}█████████''${reset}
      ''${redf}   ██  ████''${reset} ''${greenf}██  ████ ''${reset}''${yellowf}████    ''${reset} ''${bluef}████  ██''${reset} ''${purplef}████    ''${reset} ''${cyanf}█████    ''${reset}
      ''${redf}   ██    ██''${reset} ''${greenf}██████   ''${reset}''${yellowf}████████''${reset} ''${bluef}██████  ''${reset} ''${purplef}████████''${reset} ''${cyanf}██       ''${reset}

      EOF
    '')
    (writeScriptBin "c-bars" ''
      #!/usr/bin/env bash

      for f in {0..6}; do
        echo -en "\033[$((f+41))m\033[$((f+30))m██▓▒░"
      done
      echo -en "\033[37m██"

      echo -e "\033[0m"

      for f in {0..6}; do
        echo -en "\033[$((f+41))m\033[1;$((f+30))m██▓▒░"
      done
      echo -en "\033[1;37m██"

      echo -e "\033[0m"
    '')
    (writeScriptBin "c-batman" ''
      #!/usr/bin/env bash
      #
      # ANSI color scheme script by pfh
      #
      # Initializing mod by lolilolicon from Archlinux
      #

      f=3 b=4
      for j in f b; do
        for i in {0..7}; do
          printf -v $j$i %b "\e[''${!j}''${i}m"
        done
      done
      bld=$'\e[1m'
      rst=$'\e[0m'
      inv=$'\e[7m'

      cat << EOF

         $f3       ██████████████████████████████████████
         $f3     ██████████████████████████████████████████
         $f3   ██████   ████████████████████████████   ██████
         $f3 █████    ████████████  ████  ████████████    █████
         $f3 ███      ████████████        ████████████      ███
         $f3 ███                                            ███
         $f3 ███                                            ███
         $f3 ███      █████████  ████  ████  █████████      ███
         $f3 █████    ███████████████  ███████████████    █████
         $f3   ██████   ████████████████████████████   ██████
         $f3     ██████████████████████████████████████████
         $f3       ██████████████████████████████████████
         $rst
      EOF
    '')
    (writeScriptBin "c-block" ''
      #!/usr/bin/env bash

      # ANSI Color -- use these variables to easily have different color
      #    and format output. Make sure to output the reset sequence after
      #    colors (f = foreground, b = background), and use the 'off'
      #    feature for anything you turn on.

      initializeANSI()
      {
        esc=""

        blackf="''${esc}[30m";   redf="''${esc}[31m";    greenf="''${esc}[32m"
        yellowf="''${esc}[33m"   bluef="''${esc}[34m";   purplef="''${esc}[35m"
        cyanf="''${esc}[36m";    whitef="''${esc}[37m"

        blackb="''${esc}[1;30m";   redb="''${esc}[1;31m";    greenb="''${esc}[1;32m"
        yellowb="''${esc}[1;33m"   blueb="''${esc}[1;34m";   purpleb="''${esc}[1;35m"
        cyanb="''${esc}[1;36m";    whiteb="''${esc}[1;37m"

        boldon="''${esc}[1m";    boldoff="''${esc}[22m"
        italicson="''${esc}[3m"; italicsoff="''${esc}[23m"
        ulon="''${esc}[4m";      uloff="''${esc}[24m"
        invon="''${esc}[7m";     invoff="''${esc}[27m"

        reset="''${esc}[0m"
      }

      initializeANSI

      cat << EOF

      ''${blackf}████''${reset}''${blackb}████''${reset} ''${redf}████''${reset}''${redb}████''${reset} ''${greenf}████''${reset}''${greenb}████''${reset} ''${yellowf}████''${reset}''${yellowb}████''${reset} ''${bluef}████''${reset}''${blueb}████''${reset} ''${purplef}████''${reset}''${purpleb}████''${reset} ''${cyanf}████''${reset}''${cyanb}████''${reset} ''${whitef}████''${reset}''${whiteb}████''${reset}
      ''${blackf}████''${reset}''${blackb}████''${reset} ''${redf}████''${reset}''${redb}████''${reset} ''${greenf}████''${reset}''${greenb}████''${reset} ''${yellowf}████''${reset}''${yellowb}████''${reset} ''${bluef}████''${reset}''${blueb}████''${reset} ''${purplef}████''${reset}''${purpleb}████''${reset} ''${cyanf}████''${reset}''${cyanb}████''${reset} ''${whitef}████''${reset}''${whiteb}████''${reset}
      ''${blackf}████''${reset}''${blackb}████''${reset} ''${redf}████''${reset}''${redb}████''${reset} ''${greenf}████''${reset}''${greenb}████''${reset} ''${yellowf}████''${reset}''${yellowb}████''${reset} ''${bluef}████''${reset}''${blueb}████''${reset} ''${purplef}████''${reset}''${purpleb}████''${reset} ''${cyanf}████''${reset}''${cyanb}████''${reset} ''${whitef}████''${reset}''${whiteb}████''${reset}

      EOF
    '')
    (writeScriptBin "c-blocks" ''
      #!/bin/sh

      # ANSI Color -- use these variables to easily have different color
      #    and format output. Make sure to output the reset sequence after
      #    colors (f = foreground, b = background), and use the 'off'
      #    feature for anything you turn on.

      initializeANSI()
      {
        esc=""

        blackf="''${esc}[30m";   redf="''${esc}[31m";    greenf="''${esc}[32m"
        yellowf="''${esc}[33m"   bluef="''${esc}[34m";   purplef="''${esc}[35m"
        cyanf="''${esc}[36m";    whitef="''${esc}[37m"

        blackb="''${esc}[40m";   redb="''${esc}[41m";    greenb="''${esc}[42m"
        yellowb="''${esc}[43m"   blueb="''${esc}[44m";   purpleb="''${esc}[45m"
        cyanb="''${esc}[46m";    whiteb="''${esc}[47m"

        boldon="''${esc}[1m";    boldoff="''${esc}[22m"
        italicson="''${esc}[3m"; italicsoff="''${esc}[23m"
        ulon="''${esc}[4m";      uloff="''${esc}[24m"
        invon="''${esc}[7m";     invoff="''${esc}[27m"

        reset="''${esc}[0m"
      }

      # note in this first use that switching colors doesn't require a reset
      # first - the new color overrides the old one.

      initializeANSI

      cat << EOF

       ''${redf}▀ █''${reset} ''${boldon}''${redf}█ ▀''${reset}   ''${greenf}▀ █''${reset} ''${boldon}''${greenf}█ ▀''${reset}   ''${yellowf}▀ █''${reset} ''${boldon}''${yellowf}█ ▀''${reset}   ''${bluef}▀ █''${reset} ''${boldon}''${bluef}█ ▀''${reset}   ''${purplef}▀ █''${reset} ''${boldon}''${purplef}█ ▀''${reset}   ''${cyanf}▀ █''${reset} ''${boldon}''${cyanf}█ ▀''${reset}
       ''${redf}██''${reset}  ''${boldon}''${redf} ██''${reset}   ''${greenf}██''${reset}   ''${boldon}''${greenf}██''${reset}   ''${yellowf}██''${reset}   ''${boldon}''${yellowf}██''${reset}   ''${bluef}██''${reset}   ''${boldon}''${bluef}██''${reset}   ''${purplef}██''${reset}   ''${boldon}''${purplef}██''${reset}   ''${cyanf}██''${reset}   ''${boldon}''${cyanf}██''${reset}
       ''${redf}▄ █''${reset}''${boldon}''${redf} █ ▄ ''${reset}  ''${greenf}▄ █ ''${reset}''${boldon}''${greenf}█ ▄''${reset}   ''${yellowf}▄ █ ''${reset}''${boldon}''${yellowf}█ ▄''${reset}   ''${bluef}▄ █ ''${reset}''${boldon}''${bluef}█ ▄''${reset}   ''${purplef}▄ █ ''${reset}''${boldon}''${purplef}█ ▄''${reset}   ''${cyanf}▄ █ ''${reset}''${boldon}''${cyanf}█ ▄''${reset}

      EOF
    '')
    (writeScriptBin "c-blocks2" ''
      #!/bin/sh

      # ANSI Color -- use these variables to easily have different color
      #    and format output. Make sure to output the reset sequence after
      #    colors (f = foreground, b = background), and use the 'off'
      #    feature for anything you turn on.

      initializeANSI()
      {
        esc=""

        blackf="''${esc}[30m";   redf="''${esc}[31m";    greenf="''${esc}[32m"
        yellowf="''${esc}[33m"   bluef="''${esc}[34m";   purplef="''${esc}[35m"
        cyanf="''${esc}[36m";    whitef="''${esc}[37m"

        blackb="''${esc}[40m";   redb="''${esc}[41m";    greenb="''${esc}[42m"
        yellowb="''${esc}[43m"   blueb="''${esc}[44m";   purpleb="''${esc}[45m"
        cyanb="''${esc}[46m";    whiteb="''${esc}[47m"

        boldon="''${esc}[1m";    boldoff="''${esc}[22m"
        italicson="''${esc}[3m"; italicsoff="''${esc}[23m"
        ulon="''${esc}[4m";      uloff="''${esc}[24m"
        invon="''${esc}[7m";     invoff="''${esc}[27m"

        reset="''${esc}[0m"
      }

      # note in this first use that switching colors doesn't require a reset
      # first - the new color overrides the old one.

      initializeANSI

      cat << EOF

       ''${redf}▒▒▒▒''${reset} ''${boldon}''${redf}▒▒''${reset}   ''${greenf}▒▒▒▒''${reset} ''${boldon}''${greenf}▒▒''${reset}   ''${yellowf}▒▒▒▒''${reset} ''${boldon}''${yellowf}▒▒''${reset}   ''${bluef}▒▒▒▒''${reset} ''${boldon}''${bluef}▒▒''${reset}   ''${purplef}▒▒▒▒''${reset} ''${boldon}''${purplef}▒▒''${reset}   ''${cyanf}▒▒▒▒''${reset} ''${boldon}''${cyanf}▒▒''${reset}
       ''${redf}▒▒ ■''${reset} ''${boldon}''${redf}▒▒''${reset}   ''${greenf}▒▒ ■''${reset} ''${boldon}''${greenf}▒▒''${reset}   ''${yellowf}▒▒ ■''${reset} ''${boldon}''${yellowf}▒▒''${reset}   ''${bluef}▒▒ ■''${reset} ''${boldon}''${bluef}▒▒''${reset}   ''${purplef}▒▒ ■''${reset} ''${boldon}''${purplef}▒▒''${reset}   ''${cyanf}▒▒ ■''${reset} ''${boldon}''${cyanf}▒▒''${reset}
       ''${redf}▒▒ ''${reset}''${boldon}''${redf}▒▒▒▒''${reset}   ''${greenf}▒▒ ''${reset}''${boldon}''${greenf}▒▒▒▒''${reset}   ''${yellowf}▒▒ ''${reset}''${boldon}''${yellowf}▒▒▒▒''${reset}   ''${bluef}▒▒ ''${reset}''${boldon}''${bluef}▒▒▒▒''${reset}   ''${purplef}▒▒ ''${reset}''${boldon}''${purplef}▒▒▒▒''${reset}   ''${cyanf}▒▒ ''${reset}''${boldon}''${cyanf}▒▒▒▒''${reset}

      EOF
    '')
    (writeScriptBin "c-candy" ''
      #!/bin/sh

      f0='[30m'; f1='[31m'; f2='[32m'; f3='[33m'; f4='[34m'; f5='[35m'; f6='[36m'; f7='[37m'
      b0='[40m'; b1='[41m'; b2='[42m'; b4='[44m'; b4='[44m'; b5='[45m'; b6='[46m'; b7='[47m'

      B='[1m'
      R='[0m'
      I='[7m'

      if [ "$1" = "-v" ] || [ "$1" = "--vertical" ]
      then

      cat << EOF

       ''${f0}████████
       ''${f0}██▒▒▒▒''${f0}██
       ''${f0}██▒▒▒▒''${f0}██
       ''${f0}████████

       ''${f1}████████
       ''${f1}██▒▒▒▒''${f1}██
       ''${f1}██▒▒▒▒''${f1}██
       ''${f1}████████

       ''${f2}████████
       ''${f2}██▒▒▒▒''${f2}██
       ''${f2}██▒▒▒▒''${f2}██
       ''${f2}████████

       ''${f3}████████
       ''${f3}██▒▒▒▒''${f3}██
       ''${f3}██▒▒▒▒''${f3}██
       ''${f3}████████

       ''${f4}████████
       ''${f4}██▒▒▒▒''${f4}██
       ''${f4}██▒▒▒▒''${f4}██
       ''${f4}████████

       ''${f5}████████
       ''${f5}██▒▒▒▒''${f5}██
       ''${f5}██▒▒▒▒''${f5}██
       ''${f5}████████

       ''${f6}████████
       ''${f6}██▒▒▒▒''${f6}██
       ''${f6}██▒▒▒▒''${f6}██
       ''${f6}████████

       ''${f7}████████
       ''${f7}██▒▒▒▒''${f7}██
       ''${f7}██▒▒▒▒''${f7}██
       ''${f7}████████''${R}

      EOF

      else

      cat << EOF

       ''${f0}████████ ''${f1}████████ ''${f2}████████ ''${f3}████████ ''${f4}████████ ''${f5}████████ ''${f6}████████ ''${f7}████████
       ''${f0}██▒▒▒▒''${f0}██ ''${f1}██▒▒▒▒''${R}''${f1}██ ''${f2}██▒▒▒▒''${R}''${f2}██ ''${f3}██▒▒▒▒''${R}''${f3}██ ''${f4}██▒▒▒▒''${R}''${f4}██ ''${f5}██▒▒▒▒''${R}''${f5}██ ''${f6}██▒▒▒▒''${R}''${f6}██ ''${f7}██▒▒▒▒''${R}''${f7}██
       ''${f0}██▒▒▒▒''${f0}██ ''${f1}██▒▒▒▒''${R}''${f1}██ ''${f2}██▒▒▒▒''${R}''${f2}██ ''${f3}██▒▒▒▒''${R}''${f3}██ ''${f4}██▒▒▒▒''${R}''${f4}██ ''${f5}██▒▒▒▒''${R}''${f5}██ ''${f6}██▒▒▒▒''${R}''${f6}██ ''${f7}██▒▒▒▒''${R}''${f7}██
       ''${f0}████████ ''${f1}████████ ''${f2}████████ ''${f3}████████ ''${f4}████████ ''${f5}████████ ''${f6}████████ ''${f7}████████''${R}

      EOF

      fi
    '')
    (writeScriptBin "c-determination" ''
      #!/usr/bin/env bash
      # https://github.com/roberoonska/dotfiles/tree/master/colorscripts

      f=3 b=4
      for j in f b; do
        for i in {0..7}; do
          printf -v $j$i %b "\e[''${!j}''${i}m"
        done
      done
      bld=$'\e[1m'
      rst=$'\e[0m'
      inv=$'\e[7m'
      cat << EOF
      ''${f1}  ▄▄        ▄▄   ''${f2}  ▄▄        ▄▄   ''${f3}  ▄▄        ▄▄   ''${f4}  ▄▄        ▄▄   ''${f5}  ▄▄        ▄▄   ''${f6}  ▄▄        ▄▄
      ''${f1}▄█████▄  ▄█████▄ ''${f2}▄█████▄  ▄█████▄ ''${f3}▄█████▄  ▄█████▄ ''${f4}▄█████▄  ▄█████▄ ''${f5}▄█████▄  ▄█████▄ ''${f6}▄█████▄  ▄█████▄
      ''${f1}███████▄▄███████ ''${f2}███████▄▄███████ ''${f3}███████▄▄███████ ''${f4}███████▄▄███████ ''${f5}███████▄▄███████ ''${f6}███████▄▄███████
      ''${f1}████████████████ ''${f2}████████████████ ''${f3}████████████████ ''${f4}████████████████ ''${f5}████████████████ ''${f6}████████████████
      ''${f1}████████████████ ''${f2}████████████████ ''${f3}████████████████ ''${f4}████████████████ ''${f5}████████████████ ''${f6}████████████████
      ''${f1}████████████████ ''${f2}████████████████ ''${f3}████████████████ ''${f4}████████████████ ''${f5}████████████████ ''${f6}████████████████
      ''${f1}  ████████████   ''${f2}  ████████████   ''${f3}  ████████████   ''${f4}  ████████████   ''${f5}  ████████████   ''${f6}  ████████████
      ''${f1}    ████████     ''${f2}    ████████     ''${f3}    ████████     ''${f4}    ████████     ''${f5}    ████████     ''${f6}    ████████
      ''${f1}      ████       ''${f2}      ████       ''${f3}      ████       ''${f4}      ████       ''${f5}      ████       ''${f6}      ████       ''${bld}
      ''${f1}  ▄▄        ▄▄   ''${f2}  ▄▄        ▄▄   ''${f3}  ▄▄        ▄▄   ''${f4}  ▄▄        ▄▄   ''${f5}  ▄▄        ▄▄   ''${f6}  ▄▄        ▄▄
      ''${f1}▄█████▄  ▄█████▄ ''${f2}▄█████▄  ▄█████▄ ''${f3}▄█████▄  ▄█████▄ ''${f4}▄█████▄  ▄█████▄ ''${f5}▄█████▄  ▄█████▄ ''${f6}▄█████▄  ▄█████▄
      ''${f1}███████▄▄███████ ''${f2}███████▄▄███████ ''${f3}███████▄▄███████ ''${f4}███████▄▄███████ ''${f5}███████▄▄███████ ''${f6}███████▄▄███████
      ''${f1}████████████████ ''${f2}████████████████ ''${f3}████████████████ ''${f4}████████████████ ''${f5}████████████████ ''${f6}████████████████
      ''${f1}████████████████ ''${f2}████████████████ ''${f3}████████████████ ''${f4}████████████████ ''${f5}████████████████ ''${f6}████████████████
      ''${f1}████████████████ ''${f2}████████████████ ''${f3}████████████████ ''${f4}████████████████ ''${f5}████████████████ ''${f6}████████████████
      ''${f1}  ████████████   ''${f2}  ████████████   ''${f3}  ████████████   ''${f4}  ████████████   ''${f5}  ████████████   ''${f6}  ████████████
      ''${f1}    ████████     ''${f2}    ████████     ''${f3}    ████████     ''${f4}    ████████     ''${f5}    ████████     ''${f6}    ████████
      ''${f1}      ████       ''${f2}      ████       ''${f3}      ████       ''${f4}      ████       ''${f5}      ████       ''${f6}      ████       ''${rst}

      You're filled with DETERMINATION.
      EOF
    '')
    (writeScriptBin "c-digdug" ''
      #!/bin/sh

      # ANSI Color -- use these variables to easily have different color
      #    and format output. Make sure to output the reset sequence after
      #    colors (f = foreground, b = background), and use the 'off'
      #    feature for anything you turn on.

      initializeANSI()
      {
       esc=""

        blackf="''${esc}[30m";   redf="''${esc}[31m";    greenf="''${esc}[32m"
        yellowf="''${esc}[33m"   bluef="''${esc}[34m";   purplef="''${esc}[35m"
        cyanf="''${esc}[36m";    whitef="''${esc}[37m"

        blackb="''${esc}[40m";   redb="''${esc}[41m";    greenb="''${esc}[42m"
        yellowb="''${esc}[43m"   blueb="''${esc}[44m";   purpleb="''${esc}[45m"
        cyanb="''${esc}[46m";    whiteb="''${esc}[47m"

        boldon="''${esc}[1m";    boldoff="''${esc}[22m"
        italicson="''${esc}[3m"; italicsoff="''${esc}[23m"
        ulon="''${esc}[4m";      uloff="''${esc}[24m"
        invon="''${esc}[7m";     invoff="''${esc}[27m"

        reset="''${esc}[0m"
      }

      # note in this first use that switching colors doesn't require a reset
      # first - the new color overrides the old one.

      initializeANSI

      cat << EOF
       ''${boldon}''${whitef}    ▄▄▄''${reset}
       ''${boldon}''${whitef} ▄█████▄▄ ''${reset}
       ''${boldon}''${whitef}███''${cyanb}▀▀▀▀''${blackb}▀''${cyanb}▀''${blackb}▀''${cyanb}▀''${reset}
       ''${boldon}''${whitef}███''${cyanb}▄   ''${boldoff}''${blackf}▀ ▀''${reset}''${cyanf}▀''${reset}
       ''${boldon}''${whitef} ▄''${cyanb}  ''${reset}''${boldon}''${whitef}█████▄ ''${boldoff}''${redf}█▄''${reset}
       ''${boldoff}''${redf}▀▀''${reset}''${boldon}''${redb}''${whitef}▄''${cyanb}▄   ''${redb}▄▄▄''${reset}''${boldoff}''${redf}▀██▀''${reset}
       ''${boldon}''${whitef} ██▀▀▀██▀  ''${boldoff}''${redf}▀''${reset}
       ''${boldon}''${whitef} ▀▀▀▀ ▀▀▀▀''${reset}
      EOF
    '')
    (writeScriptBin "c-hashbang" ''
      #!/bin/sh

      # ANSI Color -- use these variables to easily have different color
      #    and format output. Make sure to output the reset sequence after
      #    colors (f = foreground, b = background), and use the 'off'
      #    feature for anything you turn on.

      initializeANSI()
      {
       esc=""

        blackf="''${esc}[30m";   redf="''${esc}[31m";    greenf="''${esc}[32m"
        yellowf="''${esc}[33m"   bluef="''${esc}[34m";   purplef="''${esc}[35m"
        cyanf="''${esc}[36m";    whitef="''${esc}[37m"

        blackb="''${esc}[40m";   redb="''${esc}[41m";    greenb="''${esc}[42m"
        yellowb="''${esc}[43m"   blueb="''${esc}[44m";   purpleb="''${esc}[45m"
        cyanb="''${esc}[46m";    whiteb="''${esc}[47m"

        boldon="''${esc}[1m";    boldoff="''${esc}[22m"
        italicson="''${esc}[3m"; italicsoff="''${esc}[23m"
        ulon="''${esc}[4m";      uloff="''${esc}[24m"
        invon="''${esc}[7m";     invoff="''${esc}[27m"

        reset="''${esc}[0m"
      }

      # note in this first use that switching colors doesn't require a reset
      # first - the new color overrides the old one.

      initializeANSI

      cat << EOF

       ''${reset}''${redf}▄█▄█▄ ''${reset}''${boldon}''${redf}█ ''${reset}''${greenf}▄█▄█▄ ''${reset}''${boldon}''${greenf}█ ''${reset}''${yellowf}▄█▄█▄ ''${reset}''${boldon}''${yellowf}█ ''${reset}''${bluef}▄█▄█▄ ''${reset}''${boldon}''${bluef}█ ''${reset}''${purplef}▄█▄█▄ ''${reset}''${boldon}''${purplef}█ ''${reset}''${cyanf}▄█▄█▄ ''${reset}''${boldon}''${cyanf}█''${reset}
       ''${reset}''${redf}▄█▄█▄ ''${reset}''${boldon}''${redf}▀ ''${reset}''${greenf}▄█▄█▄ ''${reset}''${boldon}''${greenf}▀ ''${reset}''${yellowf}▄█▄█▄ ''${reset}''${boldon}''${yellowf}▀ ''${reset}''${bluef}▄█▄█▄ ''${reset}''${boldon}''${bluef}▀ ''${reset}''${purplef}▄█▄█▄ ''${reset}''${boldon}''${purplef}▀ ''${reset}''${cyanf}▄█▄█▄ ''${reset}''${boldon}''${cyanf}▀''${reset}
       ''${reset}''${redf} ▀ ▀  ''${reset}''${boldon}''${redf}▀ ''${reset}''${greenf} ▀ ▀  ''${reset}''${boldon}''${greenf}▀ ''${reset}''${yellowf} ▀ ▀  ''${reset}''${boldon}''${yellowf}▀ ''${reset}''${bluef} ▀ ▀  ''${reset}''${boldon}''${bluef}▀ ''${reset}''${purplef} ▀ ▀  ''${reset}''${boldon}''${purplef}▀ ''${reset}''${cyanf} ▀ ▀  ''${reset}''${boldon}''${cyanf}▀''${reset}
      EOF
    '')
    (writeScriptBin "c-hexblock" ''
      #!/usr/bin/env bash
      # source: Meyithi, https://bbs.archlinux.org/viewtopic.php?pid=1010829#p1010829

      xdef="$(cat << EOF
      *background: #303446
      *foreground: #C6D0F5

      ! black
      *color0: #51576D
      *color8: #626880

      ! red
      *color1: #E78284
      *color9: #E78284

      ! green
      *color2: #A6D189
      *color10: #A6D189

      ! yellow
      *color3: #E5C890
      *color11: #E5C890

      ! blue
      *color4: #8CAAEE
      *color12: #8CAAEE

      ! magenta
      *color5: #F4B8E4
      *color13: #F4B8E4

      ! cyan
      *color6: #81C8BE
      *color14: #81C8BE

      ! white
      *color7: #B5BFE2
      *color15: #A5ADCE
      EOF
      )"

      colors1=("$( echo "$xdef" | sed -re '/^!/d; /^$/d; /^#/d; s/(\*color)([0-9]):/\10\2:/g;' | grep 'color[0-9]:' | sort | sed  's/^.*: *//g' )"
      )
      colors2=("$( echo "$xdef" | sed -re '/^!/d; /^$/d; /^#/d; s/(\*color)([0-9]):/\10\2:/g;' | grep 'color[0-1][0-9]:' | sort | sed  's/^.*: *//g' )"
      )

      # shellcheck disable=SC2128 disable=SC2206
      colors=($colors1 $colors2)

      echo
      for i in {0..7}; do echo -en "\e[$((30+$i))m ''${colors[i]} \u2588\u2588 \e[0m"; done
      echo
      for i in {8..15}; do echo -en "\e[1;$((22+$i))m ''${colors[i]} \u2588\u2588 \e[0m"; done
      echo -e "\n"
    '')
    (writeScriptBin "c-hypnotoad" ''
      #!/usr/bin/env perl

      # script by karabaja4
      # mail: karabaja4@archlinux.us

      my $blackFG_yellowBG = "\e[30;43m";
      my $blackFG_redBG = "\e[30;41m";
      my $blackFG_purpleBG = "\e[30;45m";

      my $yellowFG_blackBG = "\e[1;33;40m";
      my $yellowFG_redBG = "\e[1;33;41m";

      my $redFG_yellowBG = "\e[31;43m";

      my $purpleFG_yellowBG = "\e[35;43m";
      my $purpleFG_blueBG = "\e[1;35;44m";

      my $end = "\e[0m";

      print "
                     ''${blackFG_yellowBG},'${"\${blackFG_redBG}"}`''${blackFG_yellowBG}`.._''${end}   ''${blackFG_yellowBG},'${"\${blackFG_redBG}"}`''${end}''${blackFG_yellowBG}`.''${end}
                    ''${blackFG_yellowBG}:''${blackFG_redBG},''${yellowFG_blackBG}--.''${end}''${blackFG_redBG}_''${blackFG_yellowBG}:)\\,:''${blackFG_redBG},''${yellowFG_blackBG}._,''${end}''${yellowFG_redBG}.''${end}''${blackFG_yellowBG}:''${end}
                    ''${blackFG_yellowBG}:`-''${yellowFG_blackBG}-''${end}''${blackFG_yellowBG},''${blackFG_yellowBG}'''${"\${end}"}''${redFG_yellowBG}@@\@''${end}''${blackFG_yellowBG}:`.''${yellowFG_redBG}.''${end}''${blackFG_yellowBG}.';\\''${end}        All Glory to
                     ''${blackFG_yellowBG}`,'${"\${end}"}''${redFG_yellowBG}@@@@@@\@''${end}''${blackFG_yellowBG}`---'${"\${redFG_yellowBG}"}@\@''${end}''${blackFG_yellowBG}`.''${end}     the HYPNOTOAD!
                     ''${blackFG_yellowBG}/''${redFG_yellowBG}@@@@@@@@@@@@@@@@\@''${end}''${blackFG_yellowBG}:''${end}
                    ''${blackFG_yellowBG}/''${redFG_yellowBG}@@@@@@@@@@@@@@@@@@\@''${end}''${blackFG_yellowBG}\\''${end}
                  ''${blackFG_yellowBG},'${"\${redFG_yellowBG}"}@@@@@@@@@@@@@@@@@@@@\@''${end}''${purpleFG_yellowBG}:\\''${end}''${blackFG_yellowBG}.___,-.''${end}
                 ''${blackFG_yellowBG}`...,---'``````-..._''${redFG_yellowBG}@@@\@''${end}''${blackFG_purpleBG}|:''${end}''${redFG_yellowBG}@@@@@@\@''${end}''${blackFG_yellowBG}\\''${end}
                   ''${blackFG_yellowBG}(                 )''${end}''${redFG_yellowBG}@@\@''${end}''${blackFG_purpleBG};:''${end}''${redFG_yellowBG}@@@\@)@@\@''${end}''${blackFG_yellowBG}\\''${end}  ''${blackFG_yellowBG}_,-.''${end}
                    ''${blackFG_yellowBG}`.              (''${end}''${redFG_yellowBG}@@\@''${end}''${blackFG_purpleBG}//''${end}''${redFG_yellowBG}@@@@@@@@@\@''${end}''${blackFG_yellowBG}`'${"\${end}"}''${redFG_yellowBG}@@@\@''${end}''${blackFG_yellowBG}\\''${end}
                     ''${blackFG_yellowBG}:               `.''${end}''${blackFG_purpleBG}//''${end}''${redFG_yellowBG}@@)@@@@@@)@@@@@,\@''${end}''${blackFG_yellowBG};''${end}
                     ''${blackFG_purpleBG}|`''${purpleFG_yellowBG}.''${blackFG_yellowBG}            ''${end}''${purpleFG_yellowBG}_''${end}''${purpleFG_yellowBG},''${blackFG_purpleBG}'/''${end}''${redFG_yellowBG}@@@@@@@)@@@@)@,'\@''${end}''${blackFG_yellowBG},'${"\${end}"}
                     ''${blackFG_yellowBG}:''${end}''${blackFG_purpleBG}`.`''${end}''${purpleFG_yellowBG}-..____..=''${end}''${blackFG_purpleBG}:.-''${end}''${blackFG_yellowBG}':''${end}''${redFG_yellowBG}@@@@@.@@@@\@_,@@,'${"\${end}"}
                    ''${redFG_yellowBG},'${"\${end}"}''${blackFG_yellowBG}\\ ''${end}''${blackFG_purpleBG}``--....''${end}''${purpleFG_blueBG}-)='${"\${end}"}''${blackFG_yellowBG}    `.''${end}''${redFG_yellowBG}_,@\@''${end}''${blackFG_yellowBG}\\''${end}    ''${redFG_yellowBG})@@\@'``._''${end}
                   ''${redFG_yellowBG}/\@''${end}''${redFG_yellowBG}_''${end}''${redFG_yellowBG}\@''${end}''${blackFG_yellowBG}`.''${end}''${blackFG_yellowBG}       ''${end}''${blackFG_redBG}(@)''${end}''${blackFG_yellowBG}      /''${end}''${redFG_yellowBG}@@@@\@''${end}''${blackFG_yellowBG})''${end}  ''${redFG_yellowBG}; / \\ \\`-.'${"\${end}"}
                  ''${redFG_yellowBG}(@@\@''${end}''${redFG_yellowBG}`-:''${end}''${blackFG_yellowBG}`.     ''${end}''${blackFG_yellowBG}`' ___..'${"\${end}"}''${redFG_yellowBG}@\@''${end}''${blackFG_yellowBG}_,-'${"\${end}"}   ''${redFG_yellowBG}|/''${end}   ''${redFG_yellowBG}`.)''${end}
                   ''${redFG_yellowBG}`-. `.`.''${end}''${blackFG_yellowBG}``-----``--''${end}''${redFG_yellowBG},@\@.'${"\${end}"}
                     ''${redFG_yellowBG}|/`.\\`'${"\${end}"}        ''${redFG_yellowBG},',');''${end}
                         ''${redFG_yellowBG}`''${end}         ''${redFG_yellowBG}(/''${end}  ''${redFG_yellowBG}(/''${end}

      ";
    '')
    (writeScriptBin "c-invaders" ''
      #!/usr/bin/env bash
      #
      # ANSI color scheme script featuring Space Invaders
      #
      # Original: http://crunchbang.org/forums/viewtopic.php?pid=126921%23p126921#p126921
      # Modified by lolilolicon
      #

      f=3 b=4
      for j in f b; do
        for i in {0..7}; do
          printf -v $j$i %b "\e[''${!j}''${i}m"
        done
      done
      bld=$'\e[1m'
      rst=$'\e[0m'

      cat << EOF

       ''${f1}  ▀▄   ▄▀     ''${f2} ▄▄▄████▄▄▄    ''${f3}  ▄██▄     ''${f4}  ▀▄   ▄▀     ''${f5} ▄▄▄████▄▄▄    ''${f6}  ▄██▄  ''${rst}
       ''${f1} ▄█▀███▀█▄    ''${f2}███▀▀██▀▀███   ''${f3}▄█▀██▀█▄   ''${f4} ▄█▀███▀█▄    ''${f5}███▀▀██▀▀███   ''${f6}▄█▀██▀█▄''${rst}
       ''${f1}█▀███████▀█   ''${f2}▀▀███▀▀███▀▀   ''${f3}▀█▀██▀█▀   ''${f4}█▀███████▀█   ''${f5}▀▀███▀▀███▀▀   ''${f6}▀█▀██▀█▀''${rst}
       ''${f1}▀ ▀▄▄ ▄▄▀ ▀   ''${f2} ▀█▄ ▀▀ ▄█▀    ''${f3}▀▄    ▄▀   ''${f4}▀ ▀▄▄ ▄▄▀ ▀   ''${f5} ▀█▄ ▀▀ ▄█▀    ''${f6}▀▄    ▄▀''${rst}

       ''${bld}''${f1}▄ ▀▄   ▄▀ ▄   ''${f2} ▄▄▄████▄▄▄    ''${f3}  ▄██▄     ''${f4}▄ ▀▄   ▄▀ ▄   ''${f5} ▄▄▄████▄▄▄    ''${f6}  ▄██▄  ''${rst}
       ''${bld}''${f1}█▄█▀███▀█▄█   ''${f2}███▀▀██▀▀███   ''${f3}▄█▀██▀█▄   ''${f4}█▄█▀███▀█▄█   ''${f5}███▀▀██▀▀███   ''${f6}▄█▀██▀█▄''${rst}
       ''${bld}''${f1}▀█████████▀   ''${f2}▀▀▀██▀▀██▀▀▀   ''${f3}▀▀█▀▀█▀▀   ''${f4}▀█████████▀   ''${f5}▀▀▀██▀▀██▀▀▀   ''${f6}▀▀█▀▀█▀▀''${rst}
       ''${bld}''${f1} ▄▀     ▀▄    ''${f2}▄▄▀▀ ▀▀ ▀▀▄▄   ''${f3}▄▀▄▀▀▄▀▄   ''${f4} ▄▀     ▀▄    ''${f5}▄▄▀▀ ▀▀ ▀▀▄▄   ''${f6}▄▀▄▀▀▄▀▄''${rst}


                                           ''${f7}▌''${rst}

                                         ''${f7}▌''${rst}

                                    ''${f7}    ▄█▄    ''${rst}
                                    ''${f7}▄█████████▄''${rst}
                                    ''${f7}▀▀▀▀▀▀▀▀▀▀▀''${rst}

      EOF
    '')
    (writeScriptBin "c-pacman" ''
      #!/bin/sh
      # Original Posted at http://crunchbang.org/forums/viewtopic.php?pid=126921%23p126921#p126921
      # [ESC] character in original post removed here.

      # ANSI Color -- use these variables to easily have different color
      #    and format output. Make sure to output the reset sequence after
      #    colors (f = foreground, b = background), and use the 'off'
      #    feature for anything you turn on.

      blackf='[30m';   redf='[31m';    greenf='[32m'
      yellowf='[33m'   bluef='[34m';   purplef='[35m'
      cyanf='[36m';    whitef='[37m'

      blackb='[40m';   redb='[41m';    greenb='[42m'
      yellowb='[43m'   blueb='[44m';   purpleb='[45m'
      cyanb='[46m';    whiteb='[47m'

      boldon='[1m';    boldoff='[22m'
      italicson='[3m'; italicsoff='[23m'
      ulon='[4m';      uloff='[24m'
      invon='[7m';     invoff='[27m'

      reset='[0m'

      # note in this first use that switching colors doesn't require a reset
      # first - the new color overrides the old one.

      #clear

      cat << EOF

       ''${yellowf}  ▄███████▄''${reset}   ''${redf}  ▄██████▄''${reset}    ''${greenf}  ▄██████▄''${reset}    ''${bluef}  ▄██████▄''${reset}    ''${purplef}  ▄██████▄''${reset}    ''${cyanf}  ▄██████▄''${reset}
       ''${yellowf}▄█████████▀▀''${reset}  ''${redf}▄''${whitef}█▀█''${redf}██''${whitef}█▀█''${redf}██▄''${reset}  ''${greenf}▄''${whitef}█▀█''${greenf}██''${whitef}█▀█''${greenf}██▄''${reset}  ''${bluef}▄''${whitef}█▀█''${bluef}██''${whitef}█▀█''${bluef}██▄''${reset}  ''${purplef}▄''${whitef}█▀█''${purplef}██''${whitef}█▀█''${purplef}██▄''${reset}  ''${cyanf}▄''${whitef}█▀█''${cyanf}██''${whitef}█▀█''${cyanf}██▄''${reset}
       ''${yellowf}███████▀''${reset}      ''${redf}█''${whitef}▄▄█''${redf}██''${whitef}▄▄█''${redf}███''${reset}  ''${greenf}█''${whitef}▄▄█''${greenf}██''${whitef}▄▄█''${greenf}███''${reset}  ''${bluef}█''${whitef}▄▄█''${bluef}██''${whitef}▄▄█''${bluef}███''${reset}  ''${purplef}█''${whitef}▄▄█''${purplef}██''${whitef}▄▄█''${purplef}███''${reset}  ''${cyanf}█''${whitef}▄▄█''${cyanf}██''${whitef}▄▄█''${cyanf}███''${reset}
       ''${yellowf}███████▄''${reset}      ''${redf}████████████''${reset}  ''${greenf}████████████''${reset}  ''${bluef}████████████''${reset}  ''${purplef}████████████''${reset}  ''${cyanf}████████████''${reset}
       ''${yellowf}▀█████████▄▄''${reset}  ''${redf}██▀██▀▀██▀██''${reset}  ''${greenf}██▀██▀▀██▀██''${reset}  ''${bluef}██▀██▀▀██▀██''${reset}  ''${purplef}██▀██▀▀██▀██''${reset}  ''${cyanf}██▀██▀▀██▀██''${reset}
       ''${yellowf}  ▀███████▀''${reset}   ''${redf}▀   ▀  ▀   ▀''${reset}  ''${greenf}▀   ▀  ▀   ▀''${reset}  ''${bluef}▀   ▀  ▀   ▀''${reset}  ''${purplef}▀   ▀  ▀   ▀''${reset}  ''${cyanf}▀   ▀  ▀   ▀''${reset}

       ''${boldon}''${yellowf}  ▄███████▄   ''${redf}  ▄██████▄    ''${greenf}  ▄██████▄    ''${bluef}  ▄██████▄    ''${purplef}  ▄██████▄    ''${cyanf}  ▄██████▄''${reset}
       ''${boldon}''${yellowf}▄█████████▀▀  ''${redf}▄''${whitef}█▀█''${redf}██''${whitef}█▀█''${redf}██▄  ''${greenf}▄''${whitef}█▀█''${greenf}██''${whitef}█▀█''${greenf}██▄  ''${bluef}▄''${whitef}█▀█''${bluef}██''${whitef}█▀█''${bluef}██▄  ''${purplef}▄''${whitef}█▀█''${purplef}██''${whitef}█▀█''${purplef}██▄  ''${cyanf}▄''${whitef}█▀█''${cyanf}██''${whitef}█▀█''${cyanf}██▄''${reset}
       ''${boldon}''${yellowf}███████▀      ''${redf}█''${whitef}▄▄█''${redf}██''${whitef}▄▄█''${redf}███  ''${greenf}█''${whitef}▄▄█''${greenf}██''${whitef}▄▄█''${greenf}███  ''${bluef}█''${whitef}▄▄█''${bluef}██''${whitef}▄▄█''${bluef}███  ''${purplef}█''${whitef}▄▄█''${purplef}██''${whitef}▄▄█''${purplef}███  ''${cyanf}█''${whitef}▄▄█''${cyanf}██''${whitef}▄▄█''${cyanf}███''${reset}
       ''${boldon}''${yellowf}███████▄      ''${redf}████████████  ''${greenf}████████████  ''${bluef}████████████  ''${purplef}████████████  ''${cyanf}████████████''${reset}
       ''${boldon}''${yellowf}▀█████████▄▄  ''${redf}██▀██▀▀██▀██  ''${greenf}██▀██▀▀██▀██  ''${bluef}██▀██▀▀██▀██  ''${purplef}██▀██▀▀██▀██  ''${cyanf}██▀██▀▀██▀██''${reset}
       ''${boldon}''${yellowf}  ▀███████▀   ''${redf}▀   ▀  ▀   ▀  ''${greenf}▀   ▀  ▀   ▀  ''${bluef}▀   ▀  ▀   ▀  ''${purplef}▀   ▀  ▀   ▀  ''${cyanf}▀   ▀  ▀   ▀''${reset}

      EOF
    '')
    (writeScriptBin "c-panes" ''
      #!/usr/bin/env bash

      # Author: GekkoP
      # Source: http://linuxbbq.org/bbs/viewtopic.php?f=4&t=1656#p33189

      f=3 b=4
      for j in f b; do
        for i in {0..7}; do
          printf -v $j$i %b "\e[''${!j}''${i}m"
        done
      done
      d=$'\e[1m'
      t=$'\e[0m'
      v=$'\e[7m'


      cat << EOF

       ''${f0}████''${d}▄''${t}  ''${f1}████''${d}▄''${t}  ''${f2}████''${d}▄''${t}  ''${f3}████''${d}▄''${t}  ''${f4}████''${d}▄''${t}  ''${f5}████''${d}▄''${t}  ''${f6}████''${d}▄''${t}  ''${f7}████''${d}▄''${t}
       ''${f0}████''${d}█''${t}  ''${f1}████''${d}█''${t}  ''${f2}████''${d}█''${t}  ''${f3}████''${d}█''${t}  ''${f4}████''${d}█''${t}  ''${f5}████''${d}█''${t}  ''${f6}████''${d}█''${t}  ''${f7}████''${d}█''${t}
       ''${f0}████''${d}█''${t}  ''${f1}████''${d}█''${t}  ''${f2}████''${d}█''${t}  ''${f3}████''${d}█''${t}  ''${f4}████''${d}█''${t}  ''${f5}████''${d}█''${t}  ''${f6}████''${d}█''${t}  ''${f7}████''${d}█''${t}
       ''${d}''${f0} ▀▀▀▀  ''${d}''${f1} ▀▀▀▀   ''${f2}▀▀▀▀   ''${f3}▀▀▀▀   ''${f4}▀▀▀▀   ''${f5}▀▀▀▀   ''${f6}▀▀▀▀   ''${f7}▀▀▀▀''${t}
      EOF
    '')
    (writeScriptBin "c-poke" ''
      #!/bin/sh
      # https://github.com/roberoonska/dotfiles/blob/master/colorscripts/poke

      initializeANSI()
      {
        esc=""

        Bf="''${esc}[30m";   rf="''${esc}[31m";    gf="''${esc}[32m"
        yf="''${esc}[33m"   bf="''${esc}[34m";   pf="''${esc}[35m"
        cf="''${esc}[36m";    wf="''${esc}[37m"

        Bb="''${esc}[40m";   rb="''${esc}[41m";    gb="''${esc}[42m"
        yb="''${esc}[43m"   bb="''${esc}[44m";   pb="''${esc}[45m"
        cb="''${esc}[46m";    wb="''${esc}[47m"

        ON="''${esc}[1m";    OFF="''${esc}[22m"
        italicson="''${esc}[3m"; italicsoff="''${esc}[23m"
        ulon="''${esc}[4m";      uloff="''${esc}[24m"
        invon="''${esc}[7m";     invoff="''${esc}[27m"

        reset="''${esc}[0m"
      }

      initializeANSI

      cat << EOF
                              ''${Bf}██████                    ''${Bf}████████                  ██              ''${Bf}████████                  ████████
                            ''${Bf}██''${gf}''${ON}██████''${OFF}''${Bf}██                ''${Bf}██''${rf}''${ON}██████''${OFF}██''${Bf}██              ██''${rf}██''${Bf}██          ''${Bf}██''${bf}''${ON}██████''${OFF}██''${Bf}████            ██''${bf}''${ON}████████''${OFF}''${Bf}██
                        ''${Bf}██████''${gf}''${ON}██████''${OFF}''${Bf}██              ''${Bf}██''${rf}''${ON}██████████''${OFF}██''${Bf}██            ██''${rf}████''${Bf}██      ''${Bf}██''${bf}''${ON}████████████''${OFF}██''${Bf}████      ████''${bf}''${ON}██████''${OFF}████''${Bf}██
                    ''${Bf}████''${gf}''${ON}████''${OFF}██''${ON}████''${OFF}██''${ON}██''${OFF}''${Bf}████          ''${Bf}██''${rf}''${ON}████████████''${OFF}''${Bf}██            ██''${rf}████''${Bf}██      ''${Bf}██''${bf}''${ON}██████████████''${OFF}''${Bf}██''${pf}██''${Bf}████  ██''${bf}''${ON}████''${OFF}██''${Bf}██''${bf}████''${Bf}██
            ''${Bf}██    ██''${gf}''${ON}██████''${OFF}████''${ON}████''${OFF}██''${ON}██████''${OFF}''${Bf}██      ''${Bf}██''${rf}''${ON}██████████████''${OFF}██''${Bf}██        ██''${rf}████''${yf}██''${rf}██''${Bf}██  ''${Bf}██''${bf}''${ON}████████████████''${OFF}██''${pf}██''${ON}██''${OFF}██''${Bf}██''${bf}██''${ON}██''${OFF}██''${Bf}██''${bf}██████''${Bf}██
          ''${Bf}██''${cf}''${ON}██''${OFF}''${Bf}██████''${gf}''${ON}████''${OFF}██''${ON}██''${OFF}██''${ON}██████''${OFF}██''${ON}██████''${OFF}''${Bf}██  ''${Bf}██''${rf}''${ON}████████''${wf}██''${OFF}''${Bf}██''${rf}''${ON}████''${OFF}██''${Bf}██        ██''${rf}██''${yf}██''${ON}██''${OFF}''${rf}██''${Bf}██  ''${Bf}██''${bf}''${ON}████████''${wf}''${ON}██''${OFF}''${Bf}██''${bf}''${ON}████''${OFF}██''${wf}''${ON}██''${OFF}''${pf}''${ON}████''${OFF}██''${Bf}██''${bf}████''${Bf}██''${bf}████''${Bf}██
          ''${Bf}██''${cf}''${ON}██████''${OFF}''${Bf}████''${gf}██''${ON}██''${OFF}██''${ON}██████████''${OFF}██''${ON}████''${OFF}''${Bf}██  ''${Bf}██''${rf}''${ON}████████''${OFF}''${Bf}████''${rf}''${ON}██''${OFF}██████''${Bf}██      ██''${rf}██''${yf}''${ON}████''${OFF}''${rf}██''${Bf}██  ''${Bf}██''${bf}██''${ON}██████''${OFF}''${Bf}████''${bf}''${ON}██''${OFF}████''${wf}''${ON}██''${pf}██████''${OFF}''${Bf}██''${bf}██''${Bf}████████
          ''${Bf}██''${cf}''${ON}████████''${OFF}██''${Bf}██''${gf}''${ON}██''${OFF}██''${ON}██████████''${OFF}██''${ON}████''${OFF}''${Bf}██  ''${Bf}██''${rf}''${ON}████████''${OFF}''${Bf}████''${rf}''${ON}██''${OFF}██████''${Bf}██        ██''${yf}''${ON}██''${OFF}''${Bf}████      ''${Bf}██''${bf}████''${ON}██''${OFF}''${Bf}████''${bf}██████''${Bf}██''${wf}''${ON}████''${pf}██''${OFF}██''${Bf}████
        ''${Bf}██''${cf}''${ON}████''${OFF}██''${ON}██''${OFF}████''${ON}██''${OFF}''${Bf}██████''${gf}''${ON}████████''${OFF}██''${ON}██''${OFF}''${Bf}██      ''${Bf}██''${rf}██''${ON}████████''${OFF}██████████''${Bf}██      ██''${rf}''${ON}██''${OFF}''${Bf}██          ''${Bf}████''${bf}████████''${Bf}████''${bf}''${ON}████''${wf}██''${OFF}''${pf}████''${Bf}██
      ''${Bf}████''${cf}██''${ON}████████████████''${OFF}''${Bf}██''${gf}██████''${Bf}████████        ''${Bf}████''${rf}██████████████████''${Bf}██  ██''${rf}''${ON}████''${OFF}''${Bf}██          ''${Bf}██''${bf}''${ON}██''${OFF}''${Bf}████████''${bf}''${ON}██████''${OFF}██''${wf}''${ON}██''${OFF}''${pf}████''${Bf}██
      ''${Bf}██''${cf}████''${ON}██████''${OFF}██''${ON}██████''${OFF}''${Bf}██''${cf}██''${Bf}██████''${cf}██████''${Bf}██            ''${Bf}██████''${rf}████''${Bf}██''${rf}██████''${Bf}████''${rf}██''${ON}██''${OFF}''${Bf}██              ''${Bf}████''${yf}''${ON}████''${OFF}''${Bf}██''${bf}''${ON}████''${OFF}██''${Bf}██''${wf}''${ON}██''${OFF}''${pf}████''${Bf}██
      ''${Bf}██''${cf}''${ON}████████''${OFF}██''${ON}██''${OFF}''${Bf}████''${cf}''${ON}██''${OFF}██████████''${Bf}██''${cf}██''${wf}''${ON}██''${OFF}''${Bf}██              ''${Bf}██''${yf}''${ON}████''${OFF}''${Bf}██''${rf}''${ON}████''${OFF}''${rf}██████''${Bf}██''${rf}██''${ON}██''${OFF}''${Bf}██                  ''${Bf}██''${yf}████''${Bf}████████''${wf}''${ON}██''${OFF}''${pf}████''${Bf}██
      ''${Bf}██''${cf}██''${ON}████████''${OFF}''${Bf}██''${rf}''${ON}██''${wf}████''${OFF}''${cf}████''${Bf}██''${cf}████''${Bf}██████                ''${Bf}██''${yf}''${ON}██████''${OFF}''${Bf}████''${rf}██████''${Bf}██''${rf}██''${Bf}██                  ''${Bf}██''${bf}██''${Bf}██''${pf}██''${yf}██████''${pf}██''${Bf}██''${wf}''${ON}██''${OFF}''${Bf}██
        ''${Bf}██''${cf}██''${ON}██████''${OFF}''${Bf}██''${rf}''${ON}██''${wf}██''${cf}██''${OFF}██''${Bf}██''${cf}████''${Bf}██                    ''${Bf}██''${wf}''${ON}██''${OFF}''${Bf}██''${yf}''${ON}██████''${OFF}''${rf}████████''${Bf}████                      ''${Bf}████████''${pf}████''${bf}██''${Bf}██''${wf}''${ON}██''${OFF}''${Bf}██
          ''${Bf}████''${cf}████████████''${Bf}██''${cf}██████''${Bf}██                      ''${Bf}██████''${yf}████''${rf}██████''${Bf}████                              ''${Bf}██████''${bf}██''${Bf}████
              ''${Bf}██████████████''${wf}''${ON}██''${OFF}''${cf}██''${wf}''${ON}██''${OFF}''${Bf}██                            ''${Bf}██████''${rf}██''${Bf}████                                  ''${Bf}██''${bf}██████''${Bf}██
                            ''${Bf}██████                                ''${Bf}██''${wf}''${ON}██''${OFF}''${rf}██''${wf}''${ON}██''${OFF}''${Bf}██                                    ''${Bf}██████
                                                                    ''${Bf}██████
      ''${reset}

      EOF
    '')
    (writeScriptBin "c-rupees" ''
      #!/bin/sh
      # https://github.com/roberoonska/dotfiles/tree/master/colorscripts

      initializeANSI()
      {
        esc=""

        Bf="''${esc}[30m";   rf="''${esc}[31m";    gf="''${esc}[32m"
        yf="''${esc}[33m"   bf="''${esc}[34m";   pf="''${esc}[35m"
        cf="''${esc}[36m";    wf="''${esc}[37m"

        Bb="''${esc}[40m";   rb="''${esc}[41m";    gb="''${esc}[42m"
        yb="''${esc}[43m"   bb="''${esc}[44m";   pb="''${esc}[45m"
        cb="''${esc}[46m";    wb="''${esc}[47m"

        ON="''${esc}[1m";    OFF="''${esc}[22m"
        italicson="''${esc}[3m"; italicsoff="''${esc}[23m"
        ulon="''${esc}[4m";      uloff="''${esc}[24m"
        invon="''${esc}[7m";     invoff="''${esc}[27m"

        reset="''${esc}[0m"
      }

      initializeANSI

      cat << EOF

                             ''${Bf}██                               ''${Bf}████                    ''${Bf}████                    ''${Bf}████                    ''${Bf}████                    ''${Bf}████
                           ''${Bf}██''${yf}██''${Bf}██                           ''${Bf}██''${gf}''${ON}██''${OFF}██''${Bf}██                ''${Bf}██''${bf}''${ON}██''${OFF}██''${Bf}██                ''${Bf}██''${rf}''${ON}██''${OFF}██''${Bf}██                ''${Bf}██''${pf}''${ON}██''${OFF}██''${Bf}██                ''${Bf}██''${cf}''${ON}██''${OFF}██''${Bf}██
                         ''${Bf}██''${yf}██████''${Bf}██                       ''${Bf}██''${gf}''${ON}████''${OFF}████''${Bf}██            ''${Bf}██''${bf}''${ON}████''${OFF}████''${Bf}██            ''${Bf}██''${rf}''${ON}████''${OFF}████''${Bf}██            ''${Bf}██''${pf}''${ON}████''${OFF}████''${Bf}██            ''${Bf}██''${cf}''${ON}████''${OFF}████''${Bf}██
                         ''${Bf}██''${yf}''${ON}██''${OFF}████''${Bf}██                     ''${Bf}██''${gf}''${ON}██████''${OFF}██████''${Bf}██        ''${Bf}██''${bf}''${ON}██████''${OFF}██████''${Bf}██        ''${Bf}██''${rf}''${ON}██████''${OFF}██████''${Bf}██        ''${Bf}██''${pf}''${ON}██████''${OFF}██████''${Bf}██        ''${Bf}██''${cf}''${ON}██████''${OFF}██████''${Bf}██
                       ''${Bf}██''${yf}██''${ON}████''${OFF}████''${Bf}██                 ''${Bf}██''${gf}''${ON}██''${OFF}██''${ON}██''${OFF}██''${Bf}██''${gf}██''${Bf}██''${gf}██''${Bf}██    ''${Bf}██''${bf}''${ON}██''${OFF}██''${ON}██''${OFF}██''${Bf}██''${bf}██''${Bf}██''${bf}██''${Bf}██    ''${Bf}██''${rf}''${ON}██''${OFF}██''${ON}██''${OFF}██''${Bf}██''${rf}██''${Bf}██''${rf}██''${Bf}██    ''${Bf}██''${pf}''${ON}██''${OFF}██''${ON}██''${OFF}██''${Bf}██''${pf}██''${Bf}██''${pf}██''${Bf}██    ''${Bf}██''${cf}''${ON}██''${OFF}██''${ON}██''${OFF}██''${Bf}██''${cf}██''${Bf}██''${cf}██''${Bf}██
                       ''${Bf}██''${yf}████''${ON}██''${OFF}████''${Bf}██                 ''${Bf}██''${gf}''${ON}████''${OFF}██████''${Bf}██''${gf}████''${Bf}██    ''${Bf}██''${bf}''${ON}████''${OFF}██████''${Bf}██''${bf}████''${Bf}██    ''${Bf}██''${rf}''${ON}████''${OFF}██████''${Bf}██''${rf}████''${Bf}██    ''${Bf}██''${pf}''${ON}████''${OFF}██████''${Bf}██''${pf}████''${Bf}██    ''${Bf}██''${cf}''${ON}████''${OFF}██████''${Bf}██''${cf}████''${Bf}██
                     ''${Bf}██''${yf}██████''${ON}████''${OFF}████''${Bf}██               ''${Bf}██''${gf}''${ON}████''${OFF}██████''${Bf}██''${gf}████''${Bf}██    ''${Bf}██''${bf}''${ON}████''${OFF}██████''${Bf}██''${bf}████''${Bf}██    ''${Bf}██''${rf}''${ON}████''${OFF}██████''${Bf}██''${rf}████''${Bf}██    ''${Bf}██''${pf}''${ON}████''${OFF}██████''${Bf}██''${pf}████''${Bf}██    ''${Bf}██''${cf}''${ON}████''${OFF}██████''${Bf}██''${cf}████''${Bf}██
                     ''${Bf}██''${yf}████████''${ON}██''${OFF}████''${Bf}██               ''${Bf}██''${gf}''${ON}████''${OFF}██████''${Bf}██''${gf}████''${Bf}██    ''${Bf}██''${bf}''${ON}████''${OFF}██████''${Bf}██''${bf}████''${Bf}██    ''${Bf}██''${rf}''${ON}████''${OFF}██████''${Bf}██''${rf}████''${Bf}██    ''${Bf}██''${pf}''${ON}████''${OFF}██████''${Bf}██''${pf}████''${Bf}██    ''${Bf}██''${cf}''${ON}████''${OFF}██████''${Bf}██''${cf}████''${Bf}██
                   ''${Bf}██████████████████████             ''${Bf}██''${gf}''${ON}████''${OFF}██████''${Bf}██''${gf}████''${Bf}██    ''${Bf}██''${bf}''${ON}████''${OFF}██████''${Bf}██''${bf}████''${Bf}██    ''${Bf}██''${rf}''${ON}████''${OFF}██████''${Bf}██''${rf}████''${Bf}██    ''${Bf}██''${pf}''${ON}████''${OFF}██████''${Bf}██''${pf}████''${Bf}██    ''${Bf}██''${cf}''${ON}████''${OFF}██████''${Bf}██''${cf}████''${Bf}██
                 ''${Bf}██''${yf}██''${Bf}██              ██''${yf}██''${Bf}██           ''${Bf}██''${gf}''${ON}████''${OFF}██████''${Bf}██''${gf}████''${Bf}██    ''${Bf}██''${bf}''${ON}████''${OFF}██████''${Bf}██''${bf}████''${Bf}██    ''${Bf}██''${rf}''${ON}████''${OFF}██████''${Bf}██''${rf}████''${Bf}██    ''${Bf}██''${pf}''${ON}████''${OFF}██████''${Bf}██''${pf}████''${Bf}██    ''${Bf}██''${cf}''${ON}████''${OFF}██████''${Bf}██''${cf}████''${Bf}██
               ''${Bf}██''${yf}██████''${Bf}██          ██''${yf}██████''${Bf}██         ''${Bf}██''${gf}''${ON}████''${OFF}██████''${Bf}██''${gf}████''${Bf}██    ''${Bf}██''${bf}''${ON}████''${OFF}██████''${Bf}██''${bf}████''${Bf}██    ''${Bf}██''${rf}''${ON}████''${OFF}██████''${Bf}██''${rf}████''${Bf}██    ''${Bf}██''${pf}''${ON}████''${OFF}██████''${Bf}██''${pf}████''${Bf}██    ''${Bf}██''${cf}''${ON}████''${OFF}██████''${Bf}██''${cf}████''${Bf}██
               ''${Bf}██''${yf}██████''${Bf}██          ██''${yf}''${ON}██''${OFF}████''${Bf}██         ''${Bf}██''${gf}''${ON}██''${OFF}██''${ON}██''${OFF}████''${Bf}██''${gf}████''${Bf}██    ''${Bf}██''${bf}''${ON}██''${OFF}██''${ON}██''${OFF}████''${Bf}██''${bf}████''${Bf}██    ''${Bf}██''${rf}''${ON}██''${OFF}██''${ON}██''${OFF}████''${Bf}██''${rf}████''${Bf}██    ''${Bf}██''${pf}''${ON}██''${OFF}██''${ON}██''${OFF}████''${Bf}██''${pf}████''${Bf}██    ''${Bf}██''${cf}''${ON}██''${OFF}██''${ON}██''${OFF}████''${Bf}██''${cf}████''${Bf}██
             ''${Bf}██''${yf}██████████''${Bf}██      ██''${yf}██''${ON}████''${OFF}████''${Bf}██       ''${Bf}██''${gf}██████''${ON}██''${OFF}''${Bf}██''${gf}██''${Bf}██''${gf}██''${Bf}██    ''${Bf}██''${bf}██████''${ON}██''${OFF}''${Bf}██''${bf}██''${Bf}██''${bf}██''${Bf}██    ''${Bf}██''${rf}██████''${ON}██''${OFF}''${Bf}██''${rf}██''${Bf}██''${rf}██''${Bf}██    ''${Bf}██''${pf}██████''${ON}██''${OFF}''${Bf}██''${pf}██''${Bf}██''${pf}██''${Bf}██    ''${Bf}██''${cf}██████''${ON}██''${OFF}''${Bf}██''${cf}██''${Bf}██''${cf}██''${Bf}██
             ''${Bf}██''${yf}''${ON}██''${OFF}████████''${Bf}██      ██''${yf}████''${ON}██''${OFF}████''${Bf}██         ''${Bf}██''${gf}████████████''${Bf}██        ''${Bf}██''${bf}████████████''${Bf}██        ''${Bf}██''${rf}████████████''${Bf}██        ''${Bf}██''${pf}████████████''${Bf}██        ''${Bf}██''${cf}████████████''${Bf}██
           ''${Bf}██''${yf}██''${ON}████''${OFF}████████''${Bf}██  ██''${yf}██████''${ON}████''${OFF}████''${Bf}██         ''${Bf}██''${gf}████████''${Bf}██            ''${Bf}██''${bf}████████''${Bf}██            ''${Bf}██''${rf}████████''${Bf}██            ''${Bf}██''${pf}████████''${Bf}██            ''${Bf}██''${cf}████████''${Bf}██
           ''${Bf}██''${yf}████''${ON}██''${OFF}████████''${Bf}██  ██''${yf}████████''${ON}██''${OFF}████''${Bf}██           ''${Bf}██''${gf}████''${Bf}██                ''${Bf}██''${bf}████''${Bf}██                ''${Bf}██''${rf}████''${Bf}██                ''${Bf}██''${pf}████''${Bf}██                ''${Bf}██''${cf}████''${Bf}██
           ''${Bf}██████████████████████████████████████             ''${Bf}████                    ''${Bf}████                    ''${Bf}████                    ''${Bf}████                    ''${Bf}████''${reset}

      EOF
    '')
    (writeScriptBin "c-scheme" ''
      #!/usr/bin/env bash
      # Original: http://frexx.de/xterm-256-notes/ [dead link 2013-11-21]
      #           http://frexx.de/xterm-256-notes/data/colortable16.sh [dead link 2013-11-21]
      # Modified by Aaron Griffin
      # and further by Kazuo Teramoto
      FGNAMES=(' black ' '  red  ' ' green ' ' yellow' '  blue ' 'magenta' '  cyan ' ' white ')
      BGNAMES=('DFT' 'BLK' 'RED' 'GRN' 'YEL' 'BLU' 'MAG' 'CYN' 'WHT')

      echo "     ┌──────────────────────────────────────────────────────────────────────────┐"
      for b in {0..8}; do
        ((b>0)) && bg=$((b+39))

        echo -en "\033[0m ''${BGNAMES[b]} │ "

        for f in {0..7}; do
          echo -en "\033[''${bg}m\033[$((f+30))m ''${FGNAMES[f]} "
        done

        echo -en "\033[0m │"
        echo -en "\033[0m\n\033[0m     │ "

        for f in {0..7}; do
          echo -en "\033[''${bg}m\033[1;$((f+30))m ''${FGNAMES[f]} "
        done

        echo -en "\033[0m │"
        echo -e "\033[0m"

        ((b<8)) &&
        echo "     ├──────────────────────────────────────────────────────────────────────────┤"
      done
      echo "     └──────────────────────────────────────────────────────────────────────────┘"
    '')
    (writeScriptBin "c-scheme-alt" ''
      #!/usr/bin/env bash
      # Original: http://frexx.de/xterm-256-notes/ [dead link 2013-11-21]
      #           http://frexx.de/xterm-256-notes/data/colortable16.sh [dead link 2013-11-21]
      # Modified by Aaron Griffin
      # and further by Kazuo Teramoto


      FGNAMES=(' black ' '  red  ' ' green ' ' yellow' '  blue ' 'magenta' '  cyan ' ' white ')
      BGNAMES=('DFT' 'BLK' 'RED' 'GRN' 'YEL' 'BLU' 'MAG' 'CYN' 'WHT')
      echo "     ----------------------------------------------------------------------------"
      for b in $(seq 0 8); do
          if [ "$b" -gt 0 ]; then
            bg=$(($b+39))
          fi

          echo -en "\033[0m ''${BGNAMES[$b]} : "
          for f in $(seq 0 7); do
            echo -en "\033[''${bg}m\033[$(($f+30))m ''${FGNAMES[$f]} "
          done
          echo -en "\033[0m :"

          echo -en "\033[0m\n\033[0m     : "
          for f in $(seq 0 7); do
            echo -en "\033[''${bg}m\033[1;$(($f+30))m ''${FGNAMES[$f]} "
          done
          echo -en "\033[0m :"
              echo -e "\033[0m"

        if [ "$b" -lt 8 ]; then
          echo "     ----------------------------------------------------------------------------"
        fi
      done
      echo "     ----------------------------------------------------------------------------"
    '')
    (writeScriptBin "c-skulls" ''
      #!/usr/bin/env bash
      #
      # ANSI color scheme script by pfh
      #
      # Initializing mod by lolilolicon from Archlinux
      # https://github.com/roberoonska/dotfiles/tree/master/colorscripts
      #

      f=3 b=4
      for j in f b; do
        for i in {0..7}; do
          printf -v $j$i %b "\e[''${!j}''${i}m"
        done
      done
      bld=$'\e[1m'
      rst=$'\e[0m'
      inv=$'\e[7m'
      w=$'\e[37m'
      cat << EOF

      ''${f1}  ▄▄▄▄▄▄▄   ''${f2}  ▄▄▄▄▄▄▄   ''${f3}  ▄▄▄▄▄▄▄   ''${f4}  ▄▄▄▄▄▄▄   ''${f5}  ▄▄▄▄▄▄▄   ''${f6}  ▄▄▄▄▄▄▄
      ''${f1}▄█▀     ▀█▄ ''${f2}▄█▀     ▀█▄ ''${f3}▄█▀     ▀█▄ ''${f4}▄█▀     ▀█▄ ''${f5}▄█▀     ▀█▄ ''${f6}▄█▀     ▀█▄
      ''${f1}█         █ ''${f2}█         █ ''${f3}█         █ ''${f4}█         █ ''${f5}█         █ ''${f6}█         █
      ''${f1}███ ▄ ██  █ ''${f2}███ ▄ ██  █ ''${f3}███ ▄ ██  █ ''${f4}███ ▄ ██  █ ''${f5}███ ▄ ██  █ ''${f6}███ ▄ ██  █
      ''${f1}█▄     ▄▄██ ''${f2}█▄     ▄▄██ ''${f3}█▄     ▄▄██ ''${f4}█▄     ▄▄██ ''${f5}█▄     ▄▄██ ''${f6}█▄     ▄▄██
      ''${f1} █▄█▄█▄██▀  ''${f2} █▄█▄█▄██▀  ''${f3} █▄█▄█▄██▀  ''${f4} █▄█▄█▄██▀  ''${f5} █▄█▄█▄██▀  ''${f6} █▄█▄█▄██▀  ''${bld}
      ''${f1}  ▄▄▄▄▄▄▄   ''${f2}  ▄▄▄▄▄▄▄   ''${f3}  ▄▄▄▄▄▄▄   ''${f4}  ▄▄▄▄▄▄▄   ''${f5}  ▄▄▄▄▄▄▄   ''${f6}  ▄▄▄▄▄▄▄
      ''${f1}▄█▀     ▀█▄ ''${f2}▄█▀     ▀█▄ ''${f3}▄█▀     ▀█▄ ''${f4}▄█▀     ▀█▄ ''${f5}▄█▀     ▀█▄ ''${f6}▄█▀     ▀█▄
      ''${f1}█         █ ''${f2}█         █ ''${f3}█         █ ''${f4}█         █ ''${f5}█         █ ''${f6}█         █
      ''${f1}███ ▄ ██  █ ''${f2}███ ▄ ██  █ ''${f3}███ ▄ ██  █ ''${f4}███ ▄ ██  █ ''${f5}███ ▄ ██  █ ''${f6}███ ▄ ██  █
      ''${f1}█▄     ▄▄██ ''${f2}█▄     ▄▄██ ''${f3}█▄     ▄▄██ ''${f4}█▄     ▄▄██ ''${f5}█▄     ▄▄██ ''${f6}█▄     ▄▄██
      ''${f1} █▄█▄█▄██▀  ''${f2} █▄█▄█▄██▀  ''${f3} █▄█▄█▄██▀  ''${f4} █▄█▄█▄██▀  ''${f5} █▄█▄█▄██▀  ''${f6} █▄█▄█▄██▀
      ''${rst}
      EOF
    '')
    (writeScriptBin "c-skulls2" ''
      #!/usr/bin/env bash
      # https://github.com/roberoonska/dotfiles/tree/master/colorscripts

      f=3 b=4
      for j in f b; do
        for i in {0..7}; do
          printf -v $j$i %b "\e[''${!j}''${i}m"
        done
      done
      bld=$'\e[1m'
      rst=$'\e[0m'
      inv=$'\e[7m'
      cat << EOF

      ''${f1}▄█       █▄ ''${f2}▄█       █▄ ''${f3}▄█       █▄ ''${f4}▄█       █▄ ''${f5}▄█       █▄ ''${f6}▄█       █▄
      ''${f1}  ▄█████▄   ''${f2}  ▄█████▄   ''${f3}  ▄█████▄   ''${f4}  ▄█████▄   ''${f5}  ▄█████▄   ''${f6}  ▄█████▄
      ''${f1}  █▄▄█▄▄█   ''${f2}  █▄▄█▄▄█   ''${f3}  █▄▄█▄▄█   ''${f4}  █▄▄█▄▄█   ''${f5}  █▄▄█▄▄█   ''${f6}  █▄▄█▄▄█
      ''${f1}▄▄ █▀█▀█ ▄▄ ''${f2}▄▄ █▀█▀█ ▄▄ ''${f3}▄▄ █▀█▀█ ▄▄ ''${f4}▄▄ █▀█▀█ ▄▄ ''${f5}▄▄ █▀█▀█ ▄▄ ''${f6}▄▄ █▀█▀█ ▄▄
      ''${f1} ▀       ▀  ''${f2} ▀       ▀  ''${f3} ▀       ▀  ''${f4} ▀       ▀  ''${f5} ▀       ▀  ''${f6} ▀       ▀  ''${bld}
      ''${f1}▄█       █▄ ''${f2}▄█       █▄ ''${f3}▄█       █▄ ''${f4}▄█       █▄ ''${f5}▄█       █▄ ''${f6}▄█       █▄
      ''${f1}  ▄█████▄   ''${f2}  ▄█████▄   ''${f3}  ▄█████▄   ''${f4}  ▄█████▄   ''${f5}  ▄█████▄   ''${f6}  ▄█████▄
      ''${f1}  █▄▄█▄▄█   ''${f2}  █▄▄█▄▄█   ''${f3}  █▄▄█▄▄█   ''${f4}  █▄▄█▄▄█   ''${f5}  █▄▄█▄▄█   ''${f6}  █▄▄█▄▄█
      ''${f1}▄▄ █▀█▀█ ▄▄ ''${f2}▄▄ █▀█▀█ ▄▄ ''${f3}▄▄ █▀█▀█ ▄▄ ''${f4}▄▄ █▀█▀█ ▄▄ ''${f5}▄▄ █▀█▀█ ▄▄ ''${f6}▄▄ █▀█▀█ ▄▄
      ''${f1} ▀       ▀  ''${f2} ▀       ▀  ''${f3} ▀       ▀  ''${f4} ▀       ▀  ''${f5} ▀       ▀  ''${f6} ▀       ▀  ''${rst}
      EOF
    '')
    (writeScriptBin "c-slendy" ''
      #!/bin/sh

      initializeANSI()
      {
        esc=""

        blackf="''${esc}[30m";   redf="''${esc}[31m";    greenf="''${esc}[32m"
        yellowf="''${esc}[33m"   bluef="''${esc}[34m";   purplef="''${esc}[35m"
        cyanf="''${esc}[36m";    whitef="''${esc}[37m"

        blackb="''${esc}[40m";   redb="''${esc}[41m";    greenb="''${esc}[42m"
        yellowb="''${esc}[43m"   blueb="''${esc}[44m";   purpleb="''${esc}[45m"
        cyanb="''${esc}[46m";    whiteb="''${esc}[47m"

        boldon="''${esc}[1m";    boldoff="''${esc}[22m"
        italicson="''${esc}[3m"; italicsoff="''${esc}[23m"
        ulon="''${esc}[4m";      uloff="''${esc}[24m"
        invon="''${esc}[7m";     invoff="''${esc}[27m"

        reset="''${esc}[0m"
      }

      initializeANSI

      cat << EOF
                    ''${reset}''${blackf}|               |               |               |               |''${reset}
         ''${redf}█     █''${reset}    ''${blackf}|''${reset}    ''${greenf}█     █''${reset}    ''${blackf}|''${reset}    ''${yellowf}█     █''${reset}    ''${blackf}|''${reset}    ''${bluef}█     █''${reset}    ''${blackf}|''${reset}    ''${purplef}█     █''${reset}    ''${blackf}|''${reset}    ''${cyanf}█     █''${reset}
         ''${redf}███████''${reset}    ''${blackf}|''${reset}    ''${greenf}███████''${reset}    ''${blackf}|''${reset}    ''${yellowf}███████''${reset}    ''${blackf}|''${reset}    ''${bluef}███████''${reset}    ''${blackf}|''${reset}    ''${purplef}███████''${reset}    ''${blackf}|''${reset}    ''${cyanf}███████''${reset}
       ''${redf}███''${boldon}''${redb}██''${reset}''${redf}█''${boldon}''${redb}██''${reset}''${redf}███''${reset}  ''${blackf}|''${reset}  ''${greenf}███''${boldon}''${greenb}██''${reset}''${greenf}█''${boldon}''${greenb}██''${reset}''${greenf}███''${reset}  ''${blackf}|''${reset}  ''${yellowf}███''${boldon}''${yellowb}██''${reset}''${yellowf}█''${boldon}''${yellowb}██''${reset}''${yellowf}███''${reset}  ''${blackf}|''${reset}  ''${bluef}███''${boldon}''${blueb}██''${reset}''${bluef}█''${boldon}''${blueb}██''${reset}''${bluef}███''${reset}  ''${blackf}|''${reset}  ''${purplef}███''${boldon}''${purpleb}██''${reset}''${purplef}█''${boldon}''${purpleb}██''${reset}''${purplef}███''${reset}  ''${blackf}|''${reset}  ''${cyanf}███''${boldon}''${cyanb}██''${reset}''${cyanf}█''${boldon}''${cyanb}██''${reset}''${cyanf}███''${reset}
        ''${redf}████''${boldon}''${redb}█''${reset}''${redf}████''${reset}   ''${blackf}|''${reset}   ''${greenf}████''${boldon}''${greenb}█''${reset}''${greenf}████''${reset}   ''${blackf}|''${reset}   ''${yellowf}████''${boldon}''${yellowb}█''${reset}''${yellowf}████''${reset}   ''${blackf}|''${reset}   ''${bluef}████''${boldon}''${blueb}█''${reset}''${bluef}████''${reset}   ''${blackf}|''${reset}   ''${purplef}████''${boldon}''${purpleb}█''${reset}''${purplef}████''${reset}   ''${blackf}|''${reset}   ''${cyanf}████''${boldon}''${cyanb}█''${reset}''${cyanf}████''${reset}
        ''${redf}█ █ ''${boldon}█''${reset} ''${redf}█ █''${reset}   ''${blackf}|''${reset}   ''${greenf}█ █ ''${boldon}█''${reset} ''${greenf}█ █''${reset}   ''${blackf}|''${reset}   ''${yellowf}█ █ ''${boldon}█''${reset} ''${yellowf}█ █''${reset}   ''${blackf}|''${reset}   ''${bluef}█ █ ''${boldon}█''${reset} ''${bluef}█ █''${reset}   ''${blackf}|''${reset}   ''${purplef}█ █ ''${boldon}█''${reset} ''${purplef}█ █''${reset}   ''${blackf}|''${reset}   ''${cyanf}█ █ ''${boldon}█''${reset} ''${cyanf}█ █''${reset}
          ''${redf}█   █''${reset}     ''${blackf}|''${reset}     ''${greenf}█   █''${reset}     ''${blackf}|''${reset}     ''${yellowf}█   █''${reset}     ''${blackf}|''${reset}     ''${bluef}█   █''${reset}     ''${blackf}|''${reset}     ''${purplef}█   █''${reset}     ''${blackf}|''${reset}     ''${cyanf}█   █''${reset}
                    ''${blackf}|               |               |               |               |''${reset}
      EOF
    '')
    (writeScriptBin "c-spooky" ''
      #!/usr/bin/env bash
      #
      # ANSI color scheme script by pfh
      #
      # Initializing mod by lolilolicon from Archlinux
      #

      f=3 b=4
      for j in f b; do
        for i in {0..7}; do
          printf -v $j$i %b "\e[''${!j}''${i}m"
        done
      done
      bld=$'\e[1m'
      rst=$'\e[0m'
      inv=$'\e[7m'
      cat << EOF
      $f1    ▄▄▄      $f2    ▄▄▄      $f3    ▄▄▄      $f4    ▄▄▄      $f5    ▄▄▄      $f6    ▄▄▄
      $f1   ▀█▀██  ▄  $f2   ▀█▀██  ▄  $f3   ▀█▀██  ▄  $f4   ▀█▀██  ▄  $f5   ▀█▀██  ▄  $f6   ▀█▀██  ▄
      $f1 ▀▄██████▀   $f2 ▀▄██████▀   $f3 ▀▄██████▀   $f4 ▀▄██████▀   $f5 ▀▄██████▀   $f6 ▀▄██████▀
      $f1    ▀█████   $f2    ▀█████   $f3    ▀█████   $f4    ▀█████   $f5    ▀█████   $f6    ▀█████
      $f1       ▀▀▀▀▄ $f2       ▀▀▀▀▄ $f3       ▀▀▀▀▄ $f4       ▀▀▀▀▄ $f5       ▀▀▀▀▄ $f6       ▀▀▀▀▄
      $bld
      $f1    ▄▄▄      $f2    ▄▄▄      $f3    ▄▄▄      $f4    ▄▄▄      $f5    ▄▄▄      $f6    ▄▄▄
      $f1   ▀█▀██  ▄  $f2   ▀█▀██  ▄  $f3   ▀█▀██  ▄  $f4   ▀█▀██  ▄  $f5   ▀█▀██  ▄  $f6   ▀█▀██  ▄
      $f1 ▀▄██████▀   $f2 ▀▄██████▀   $f3 ▀▄██████▀   $f4 ▀▄██████▀   $f5 ▀▄██████▀   $f6 ▀▄██████▀
      $f1    ▀█████   $f2    ▀█████   $f3    ▀█████   $f4    ▀█████   $f5    ▀█████   $f6    ▀█████
      $f1       ▀▀▀▀▄ $f2       ▀▀▀▀▄ $f3       ▀▀▀▀▄ $f4       ▀▀▀▀▄ $f5       ▀▀▀▀▄ $f6       ▀▀▀▀▄
      $rst
      EOF
    '')
    (writeScriptBin "c-streaks" ''
      #!/usr/bin/env bash
      #
      # ANSI color scheme script by pfh
      #
      # Initializing mod by lolilolicon from Archlinux
      #

      f=3 b=4
      for j in f b; do
        for i in {0..7}; do
          printf -v $j$i %b "\e[''${!j}''${i}m"
        done
      done
      bld=$'\e[1m'
      rst=$'\e[0m'
      inv=$'\e[7m'

      cat << EOF

       $f1 ▀■▄ $f2 ▀■▄ $f3 ▀■▄ $f4 ▀■▄ $f5 ▀■▄ $f6 ▀■▄
        $bld$f1 ▀■▄ $f2 ▀■▄ $f3 ▀■▄ $f4 ▀■▄ $f5 ▀■▄ $f6 ▀■▄ $rst

      EOF
    '')
    (writeScriptBin "c-table" ''
      #!/usr/bin/env bash
      #
      #   This file echoes a bunch of color codes to the
      #   terminal to demonstrate what's available.  Each
      #   line is the color code of one foreground color,
      #   out of 17 (default + 16 escapes), followed by a
      #   test use of that color on all nine background
      #   colors (default + 8 escapes).
      #

      T=' x '   # The test text

      echo -e "\n                 40m     41m     42m     43m\
           44m     45m     46m     47m";

      for FGs in '    m' '   1m' '  30m' '1;30m' '  31m' '1;31m' '  32m' \
                 '1;32m' '  33m' '1;33m' '  34m' '1;34m' '  35m' '1;35m' \
                 '  36m' '1;36m' '  37m' '1;37m';
        do FG=''${FGs// /}
        echo -en " $FGs \033[$FG  $T  "
        for BG in 40m 41m 42m 43m 44m 45m 46m 47m;
          do echo -en "$EINS \033[$FG\033[$BG  $T  \033[0m";
        done
        echo;
      done
      echo
    '')
    (writeScriptBin "c-table-alt" ''
      #!/usr/bin/env bash
      #
      #   This file echoes a bunch of color codes to the
      #   terminal to demonstrate what's available.  Each
      #   line is the color code of one forground color,
      #   out of 17 (default + 16 escapes), followed by a
      #   test use of that color on all nine background
      #   colors (default + 8 escapes).
      #

      #T='▀▄'   # The test text

      T='▆ ▆'

      echo -e "\n                 BLK     RED     GRN     YEL\
           BLU     MAG     CYN     WHT";

      for FGs in '    m' '   1m' '  30m' '1;30m' '  31m' '1;31m' '  32m' \
                 '1;32m' '  33m' '1;33m' '  34m' '1;34m' '  35m' '1;35m' \
                 '  36m' '1;36m' '  37m' '1;37m';
        do FG=''${FGs// /}
        echo -en " $FGs \033[$FG  $T  "
        for BG in 40m 41m 42m 43m 44m 45m 46m 47m;
          do echo -en "$EINS \033[$FG\033[$BG  $T  \033[0m";
        done
        echo;
      done
      echo
    '')
    (writeScriptBin "c-tvs" ''
      #!/usr/bin/env bash
      # https://github.com/roberoonska/dotfiles/tree/master/colorscripts

      f=3 b=4
      for j in f b; do
        for i in {0..7}; do
          printf -v $j$i %b "\e[''${!j}''${i}m"
        done
      done
      bld=$'\e[1m'
      rst=$'\e[0m'
      inv=$'\e[7m'
      w=$'\e[37m'
      cat << EOF

      ''${f1} ▀▄   ▄▀  ''${f2} ▀▄   ▄▀  ''${f3} ▀▄   ▄▀  ''${f4} ▀▄   ▄▀  ''${f5} ▀▄   ▄▀  ''${f6} ▀▄   ▄▀
      ''${f1} ▄▄█▄█▄▄  ''${f2} ▄▄█▄█▄▄  ''${f3} ▄▄█▄█▄▄  ''${f4} ▄▄█▄█▄▄  ''${f5} ▄▄█▄█▄▄  ''${f6} ▄▄█▄█▄▄
      ''${f1}█''${w}██████''${f1}██ ''${f2}█''${w}██████''${f2}██ ''${f3}█''${w}██████''${f3}██ ''${f4}█''${w}██████''${f4}██ ''${f5}█''${w}██████''${f5}██ ''${f6}█''${w}██████''${f6}██
      ''${f1}█''${w}██████''${f1}██ ''${f2}█''${w}██████''${f2}██ ''${f3}█''${w}██████''${f3}██ ''${f4}█''${w}██████''${f4}██ ''${f5}█''${w}██████''${f5}██ ''${f6}█''${w}██████''${f6}██
      ''${f1}█''${w}██████''${f1}██ ''${f2}█''${w}██████''${f2}██ ''${f3}█''${w}██████''${f3}██ ''${f4}█''${w}██████''${f4}██ ''${f5}█''${w}██████''${f5}██ ''${f6}█''${w}██████''${f6}██
      ''${f1} ▀▀▀▀▀▀▀  ''${f2} ▀▀▀▀▀▀▀  ''${f3} ▀▀▀▀▀▀▀  ''${f4} ▀▀▀▀▀▀▀  ''${f5} ▀▀▀▀▀▀▀  ''${f6} ▀▀▀▀▀▀▀  ''${bld}

      ''${f1} ▀▄   ▄▀  ''${f2} ▀▄   ▄▀  ''${f3} ▀▄   ▄▀  ''${f4} ▀▄   ▄▀  ''${f5} ▀▄   ▄▀  ''${f6} ▀▄   ▄▀
      ''${f1} ▄▄█▄█▄▄  ''${f2} ▄▄█▄█▄▄  ''${f3} ▄▄█▄█▄▄  ''${f4} ▄▄█▄█▄▄  ''${f5} ▄▄█▄█▄▄  ''${f6} ▄▄█▄█▄▄
      ''${f1}█''${w}██████''${f1}██ ''${f2}█''${w}██████''${f2}██ ''${f3}█''${w}██████''${f3}██ ''${f4}█''${w}██████''${f4}██ ''${f5}█''${w}██████''${f5}██ ''${f6}█''${w}██████''${f6}██
      ''${f1}█''${w}██████''${f1}██ ''${f2}█''${w}██████''${f2}██ ''${f3}█''${w}██████''${f3}██ ''${f4}█''${w}██████''${f4}██ ''${f5}█''${w}██████''${f5}██ ''${f6}█''${w}██████''${f6}██
      ''${f1}█''${w}██████''${f1}██ ''${f2}█''${w}██████''${f2}██ ''${f3}█''${w}██████''${f3}██ ''${f4}█''${w}██████''${f4}██ ''${f5}█''${w}██████''${f5}██ ''${f6}█''${w}██████''${f6}██
      ''${f1} ▀▀▀▀▀▀▀  ''${f2} ▀▀▀▀▀▀▀  ''${f3} ▀▀▀▀▀▀▀  ''${f4} ▀▀▀▀▀▀▀  ''${f5} ▀▀▀▀▀▀▀  ''${f6} ▀▀▀▀▀▀▀  ''${rst}
      EOF
    '')
    (writeScriptBin "c-wheel" ''
      #! /bin/sh

      printf "\033[0m
          \033[49;35m|\033[49;31m|\033[101;31m|\033[41;97m|\033[49;91m|\033[49;93m|\033[0m
        \033[105;35m|\033[45;97m|\033[49;97m||\033[100;97m||\033[49;37m||\033[103;33m|\033[43;97m|\033[0m
        \033[49;95m|\033[49;94m|\033[100;37m||\033[40;97m||\033[40;37m||\033[49;33m|\033[49;32m|\033[0m
        \033[104;34m|\033[44;97m|\033[49;90m||\033[40;39m||\033[49;39m||\033[102;32m|\033[42;97m|\033[0m
          \033[49;34m|\033[49;36m|\033[106;36m|\033[46;97m|\033[49;96m|\033[49;92m|\033[0m

      "
    '')
  ];
}

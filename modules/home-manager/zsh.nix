{ lib, pkgs, ... }:
{
  home.packages = builtins.attrValues { inherit (pkgs) ruby; };
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    history.size = 10000;
    sessionVariables = {
      shell = "zsh";
    };
    localVariables = {
      ZSH_TMUX_AUTOSTART = true;
      ZSH_TMUX_AUTOCONNECT = true;
    };
    oh-my-zsh = {
      enable = true;
      plugins = [
        "colored-man-pages"
        "common-aliases"
        "emoji"
        "encode64"
        "extract"
        "git"
        "git-auto-fetch"
        "gitignore"
        "history"
        "rsync"
        "sudo"
        "tmux"
        "urltools"
        "vi-mode"
        "web-search"
      ]
      ++ (lib.optionals (!pkgs.stdenv.isDarwin) [ "systemd" ]);
      extraConfig = ''
        bindkey -M viins 'jk' vi-cmd-mode
      '';
    };
    plugins = [
      {
        name = "scm-breeze";
        file = "scm_breeze.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "scmbreeze";
          repo = "scm_breeze";
          rev = "c4fbd54a084611d275ed11bbe5cfaa9315df661a";
          sha256 = "JZ0mYCKD23wphzR9ygecAGPDrf0SCh3NACCjbe3BR7U=";
        };
      }
    ];
    dirHashes = {
      dt = "$HOME/Desktop";
      docs = "$HOME/Documents";
      dl = "$HOME/Downloads";
    };
    shellAliases = {
      # Fix for using sudo with aliases
      sudo = "sudo ";

      # Remap to newer tool alternatives
      l = "eza -lhF";
      ll = "exec_scmb_expand_args ls_with_file_shortcuts";
      la = "exec_scmb_expand_args ls_with_file_shortcuts -A";
      ls = "eza";
      lt = "ls -lhF -s date";
      lS = "ls -1lhF -s size --no-permissions --total-size --no-user --no-time";
      lart = "ls -1arF -s date";
      lrt = "ls -1rF -s date";
      lsr = "ls -lARhF";
      lsn = "ls -1";
      find = "fd";
      ff = "find --type f";
      grep = "rg --color=always";
      sgrep = "grep -L -n -H -C 5 --glob='!{.git,.svn,CVS}'";
      tree = "ls --tree";
      cat = "bat";
      cd = "exec_scmb_expand_args z";

      # Shortcuts
      ":q" = "exit";
      v = "nvim";
      wtf = "ping google.com";
      rg = "rg -S";
      rgc = "rg -S --color=always";
      gpo = "git_prune_orphans";

      # Date/Time Helpers
      timenow = "date +%s";
      week = "date +%V";
      timer = ''echo "Timer started. Stop with Ctrl-D." && date && time cat && date'';

      # Killers
      quit = "kill -3";
      yolo = "kill -9";

      # Common Python cmdline modules
      server = "python -m http.server";
      jp = "python -m json.tool";

      # tmux
      td = "tmux detach-client -E 'ZSH_TMUX_AUTOCONNECT=false tmux'";

      # Aliases
      qrdecode = "zbarimage";
    };
    initContent = ''
      cachix-push-flake() {
          nix flake archive --json \
          | jq -r '.path,(.inputs|to_entries[].value.path)' \
          | ${pkgs.cachix}/bin/cachix push "$1"
      }
      cachix-push-build() {
          nix build --no-link --print-out-paths "$1" | ${pkgs.cachix}/bin/cachix push "$2"
      }

      fit() {
          nix flake init --template github:dlubawy/nix-configs/main#"$1"
      }

      # Create a new directory and enter it
      mkd() {
          mkdir -p "$@" && cd "$_";
      }

      # Create a .tar.gz archive, using `zopfli`, `pigz` or `gzip` for compression
      targz() {
          local tmpFile="''${@%/}.tar";
          tar -cvf "''${tmpFile}" --exclude=".DS_Store" "''${@}" || return 1;

          size=$(
                  stat -f"%z" "''${tmpFile}" 2> /dev/null; # macOS `stat`
                  stat -c"%s" "''${tmpFile}" 2> /dev/null;  # GNU `stat`
                );

          local cmd="";
          if (( size < 52428800 )) && hash zopfli 2> /dev/null; then
          # the .tar file is smaller than 50 MB and Zopfli is available; use it
              cmd="zopfli";
          else
              if hash pigz 2> /dev/null; then
                  cmd="pigz";
              else
                  cmd="gzip";
          fi;
          fi;

          echo "Compressing .tar ($((size / 1000)) kB) using \`''${cmd}\`…";
          "''${cmd}" -v "''${tmpFile}" || return 1;
          [ -f "''${tmpFile}" ] && rm "''${tmpFile}";

          zippedSize=$(
                  stat -f"%z" "''${tmpFile}.gz" 2> /dev/null; # macOS `stat`
                  stat -c"%s" "''${tmpFile}.gz" 2> /dev/null; # GNU `stat`
                  );

          echo "''${tmpFile}.gz ($((zippedSize / 1000)) kB) created successfully.";
      }

      # Determine size of a file or total size of a directory
      fs() {
        if du -b /dev/null > /dev/null 2>&1; then
          local arg=-sbh;
        else
          local arg=-sh;
        fi
        if [[ -n "$@" ]]; then
          du $arg -- "$@";
        else
          du $arg .[^.]* ./*;
        fi;
      }

      # Create a data URL from a file
      dataurl() {
        local mimeType=$(file -b --mime-type "$1");
        if [[ $mimeType == text/* ]]; then
          mimeType="''${mimeType};charset=utf-8";
        fi
        echo "data:''${mimeType};base64,$(openssl base64 -in "$1" | tr -d '\n')";
      }

      # Create a git.io short URL
      gitio() {
        if [ -z "''${1}" -o -z "''${2}" ]; then
          echo "Usage: \`gitio slug url\`";
          return 1;
        fi;
        curl -i https://git.io/ -F "url=''${2}" -F "code=''${1}";
      }

      # Show all the names (CNs and SANs) listed in the SSL certificate
      # for a given domain
      getcertnames() {
        if [ -z "''${1}" ]; then
          echo "ERROR: No domain specified.";
          return 1;
        fi;

        local domain="''${1}";
        echo "Testing ''${domain}…";
        echo ""; # newline

        local tmp=$(echo -e "GET / HTTP/1.0\nEOT" \
          | openssl s_client -connect "''${domain}:443" -servername "''${domain}" 2>&1);

        if [[ "''${tmp}" = *"-----BEGIN CERTIFICATE-----"* ]]; then
          local certText=$(echo "''${tmp}" \
            | openssl x509 -text -certopt "no_aux, no_header, no_issuer, no_pubkey, \
            no_serial, no_sigdump, no_signame, no_validity, no_version");
          echo "Common Name:";
          echo ""; # newline
          echo "''${certText}" | grep "Subject:" | sed -e "s/^.*CN=//" | sed -e "s/\/emailAddress=.*//";
          echo ""; # newline
          echo "Subject Alternative Name(s):";
          echo ""; # newline
          echo "''${certText}" | grep -A 1 "Subject Alternative Name:" \
            | sed -e "2s/DNS://g" -e "s/ //g" | tr "," "\n" | tail -n +2;
          return 0;
        else
          echo "ERROR: Certificate not found.";
          return 1;
        fi;
      }

      # `tre` is a shorthand for `tree` with hidden files and color enabled, ignoring
      # the `.git` directory, listing directories first. The output gets piped into
      # `less` with options to preserve color and line numbers, unless the output is
      # small enough for one screen.
      tre() {
        eza --tree -a --color=always -I '.git|.direnv|node_modules|bower_components' --group-directories-first | less -FRNX;
      }

      # Search for a process
      psgrep() {
        ps -ef | grep $1 | grep -v grep
      }

      gitfile() {
        wget https://raw.githubusercontent.com/$1/master/$2;
      }
      ls_with_file_shortcuts () {
        local ll_output
        local ll_command
        ll_command=(eza -h --group-directories-first)
        ll_output="$("''${ll_command[@]}" -l --color=always "$@")"
        if [[ $shell == "zsh" ]]
        then
          [[ -o shwordsplit ]] && SHWORDSPLIT_ON=true
          setopt shwordsplit
        fi
        local IFS=$'\n'
        local rel_path
        for arg in "$@"
        do
          if [[ -e $arg ]]
          then
            if [[ -z $rel_path ]]
            then
              if [[ -d $arg ]]
              then
                rel_path=$arg
              else
                rel_path=.
              fi
            elif [[ -d $arg || ( -f $arg && $rel_path != . ) ]]
            then
              if [[ -f $arg ]]
              then
                arg=$PWD
              fi
              printf 'scm_breeze: Cannot list relative to both directories:\n  %s\n  %s\n' "$arg" "$rel_path" >&2
              printf 'Currently only listing a single directory is supported. See issue #274.\n' >&2
              return 1
            fi
          fi
        done
        rel_path=$("''${_abs_path_command[@]}" ''${rel_path:-$PWD})
        if [ "$(echo "$ll_output" | wc -l)" -gt "50" ]
        then
          echo -e '\033[33mToo many files to create shortcuts. Running plain ll command...\033[0m' >&2
          echo "$ll_output"
          return 1
        fi
        echo "$ll_output" | ruby -e "$(
            \cat <<EOF
      output = STDIN.read
      e = 1
      re = /^(([^ ]* +){7,8})/
      output.lines.each_with_index do |line, index|
        puts line if index == 0
        next unless line.match(re)
        puts line.sub(re, "\\\1\033[2;37m[\033[0m#{e}\033[2;37m]\033[0m" << (e < 10 ? "  " : " "))
        e += 1
      end
      EOF
          )"
        local e=1
        local ll_files=""
        local file=""
        ll_files="$("''${ll_command[@]}" --color=never "$@")"
        local IFS=$'\n'
        for file in $ll_files
        do
          file=$rel_path/$file
          export $git_env_char$e=$("''${_abs_path_command[@]}" "$file")
          if [[ ''${scmbDebug:-} = true ]]
          then
            echo "Set \$$git_env_char$e  => $file"
          fi
          let e++
        done
        if [[ $shell == "zsh" && -z $SHWORDSPLIT_ON ]]
        then
          unsetopt shwordsplit
        fi
      }
    '';
  };
}

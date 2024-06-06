{ pkgs, ... }:
{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    history.size = 10000;
    localVariables = {
      ZSH_TMUX_AUTOSTART = true;
      ZSH_TMUX_AUTOCONNECT = true;
    };
    oh-my-zsh = {
      enable = true;
      plugins = [
        "colored-man-pages"
        "colorize"
        "common-aliases"
        "emoji"
        "encode64"
        "extract"
        "git"
        "git-auto-fetch"
        "git-extras"
        "github"
        "gitignore"
        "history"
        "jsontools"
        "postgres"
        "rsync"
        "sudo"
        "tmux"
        "urltools"
        "vi-mode"
        "web-search"
      ];
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
      sudo = "sudo ";
      ":q" = "exit";
      v = "nvim";
      vimdiff = "nvim -d";

      yolo = "kill -9";
      wtf = "ping google.com";

      timenow = "date +%s";
      week = "date +%V";
      timer = ''echo "Timer started. Stop with Ctrl-D." && date && time cat && date'';

      quit = "kill -3";

      tf = "tail -f";

      server = "python -m http.server";
      qrdecode = "zbarimage";
    };
    initExtra = ''
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
        tree -aC -I '.git|node_modules|bower_components' --dirsfirst "$@" | less -FRNX;
      }

      # Search for a process
      psgrep() {
        ps -ef | grep $1 | grep -v grep
      }

      gitfile() {
        wget https://raw.githubusercontent.com/$1/master/$2;
      }
    '';
  };
}

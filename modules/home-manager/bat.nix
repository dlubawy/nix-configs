{ pkgs, lib, ... }:
let
  justSublime = pkgs.callPackage pkgs.stdenv.mkDerivation {
    pname = "just-sublime-syntax";
    version = "unstable-2025";

    src = pkgs.fetchFromGitHub {
      owner = "nk9";
      repo = "just_sublime";
      rev = "f42cdb012b6033035ee46bfeac1ecd7dca460e55";
      hash = "sha256-VxI5BPrNVOwIRwdZKm8OhTuXCVKOdG8OGKiCne9cwc8=";
    };

    # No build phase needed, just installing files
    dontBuild = true;

    installPhase = ''
      runHook preInstall

      # Install the relevant syntax files to $out
      # We copy the 'Syntax' folder which contains the .sublime-syntax files
      mkdir -p $out
      cp -r Syntax/* $out/

      # Remove the conflicting files as requested
      # Note: Paths are relative to the $out directory now
      rm "$out/Embeddings/Python (for Just).sublime-syntax"
      rm "$out/Embeddings/ShellScript (for Just).sublime-syntax"

      runHook postInstall
    '';

    meta = with lib; {
      description = "Sublime Text syntax for Justfiles";
      homepage = "https://github.com/nk9/just_sublime";
      license = licenses.mit;
      maintainers = [ ];
      platforms = platforms.all;
    };
  };
in
{
  home.file.".config/bat/syntaxes/just_sublime" = {
    enable = true;
    source = justSublime;
  };
  programs = {
    bat = {
      enable = true;
      config = {
        theme = "catppuccin-frappe";
      };
      themes = {
        catppuccin-frappe = {
          src = pkgs.fetchFromGitHub {
            owner = "catppuccin";
            repo = "bat";
            rev = "82e7ca555f805b53d2b377390e4ab38c20282e83";
            hash = "sha256-/Ob9iCVyjJDBCXlss9KwFQTuxybmSSzYRBZxOT10PZg=";
          };
          file = "./themes/Catppuccin Frappe.tmTheme";
        };
      };
    };
  };
}

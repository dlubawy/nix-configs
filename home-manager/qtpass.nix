{ lib, pkgs, ... }:
{
  home = {
    packages = with pkgs; [ qtpass ];

    sessionVariables = {
      GOPASS_GPG_OPTS = "--no-throw-keyids";
      PASSWORD_STORE_GPG_OPTS = "--no-throw-keyids";
    };

    file."Applications/QtPass.app" = lib.mkIf (pkgs.stdenv.isDarwin) {
      enable = true;
      source = "${pkgs.qtpass}/bin/QtPass.app";
      recursive = true;
    };
  };

  launchd.agents = lib.mkIf (pkgs.stdenv.isDarwin) {
    launchctl = {
      enable = true;
      config = {
        RunAtLoad = true;
        ProgramArguments = [
          "sh"
          "-c"
          "launchctl setenv GOPASS_GPG_OPTS --no-throw-keyids"
        ];
      };
    };
  };
}

{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.gui.programs.qtpass;
in
{
  options = {
    gui.programs.qtpass.enable = lib.mkEnableOption "Enable QtPass";
  };

  config = lib.mkIf cfg.enable {
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
  };
}

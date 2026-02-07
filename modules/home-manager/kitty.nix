{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.gui.programs.kitty;
in
{
  options = {
    gui.programs.kitty.enable = mkEnableOption "Enable Kitty";
  };

  config = mkIf cfg.enable {
    programs = {
      kitty = mkIf config.gui.enable {
        enable = true;
        themeFile = "Catppuccin-Frappe";
        font = {
          package = pkgs.nerd-fonts.fantasque-sans-mono;
          name = "FantasqueSansM Nerd Font Mono";
          size = 14;
        };
        keybindings = {
          "shift+enter" = "send_key f2";
        };
        settings = {
          confirm_os_window_close = 0;
          cursor_shape = "block";
          enable_audio_bell = true;
          scrollback_lines = 10000;
          update_check_interval = 0;
        };
      };
      zsh.shellAliases.icat = "kitten icat";
    };
  };
}

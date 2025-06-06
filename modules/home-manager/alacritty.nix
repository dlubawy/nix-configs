{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.gui.programs.alacritty;
  bell = {
    program = if pkgs.stdenv.isDarwin then "osascript" else "${pkgs.pipewire}/bin/pw-cat";
    args =
      if pkgs.stdenv.isDarwin then
        [
          "-e"
          "beep"
        ]
      else
        [ ];
  };

in
{
  options = {
    gui.programs.alacritty.enable = lib.mkEnableOption "Enable Alacritty";
  };

  config = lib.mkIf cfg.enable {
    programs.alacritty = {
      enable = true;
      settings = {
        env = {
          TERM = "xterm-256color";
        };
        # TODO: Add bell for linux systems
        bell.command = lib.mkIf pkgs.stdenv.isDarwin {
          program = bell.program;
          args = bell.args;
        };
        colors = {
          primary = {
            background = "#303446";
            foreground = "#c6d0f5";
            dim_foreground = "#838ba7";
            bright_foreground = "#c6d0f5";
          };
          cursor = {
            text = "#303446";
            cursor = "#f2d5cf";
          };
          vi_mode_cursor = {
            text = "#303446";
            cursor = "#babbf1";
          };
          search = {
            matches = {
              foreground = "#303446";
              background = "#a5adce";
            };
            focused_match = {
              foreground = "#303446";
              background = "#a6d189";
            };
          };
          footer_bar = {
            foreground = "#303446";
            background = "#a5adce";
          };
          hints = {
            start = {
              foreground = "#303446";
              background = "#e5c890";
            };
            end = {
              foreground = "#303446";
              background = "#a5adce";
            };
          };
          selection = {
            text = "#303446";
            background = "#f2d5cf";
          };
          normal = {
            black = "#51576d";
            red = "#e78284";
            green = "#a6d189";
            yellow = "#e5c890";
            blue = "#8caaee";
            magenta = "#f4b8e4";
            cyan = "#81c8be";
            white = "#b5bfe2";
          };

          bright = {
            black = "#626880";
            red = "#e78284";
            green = "#a6d189";
            yellow = "#e5c890";
            blue = "#8caaee";
            magenta = "#f4b8e4";
            cyan = "#81c8be";
            white = "#a5adce";
          };

          dim = {
            black = "#51576d";
            red = "#e78284";
            green = "#a6d189";
            yellow = "#e5c890";
            blue = "#8caaee";
            magenta = "#f4b8e4";
            cyan = "#81c8be";
            white = "#b5bfe2";
          };
          indexed_colors = [
            {
              index = 16;
              color = "#ef9f76";
            }
            {
              index = 17;
              color = "#f2d5cf";
            }
          ];
        };
        font = {
          size = 14;
          bold = {
            family = "FantasqueSansM Nerd Font Mono";
            style = "Bold";
          };
          bold_italic = {
            family = "FantasqueSansM Nerd Font Mono";
            style = "Bold Italic";
          };
          italic = {
            family = "FantasqueSansM Nerd Font Mono";
            style = "Italic";
          };
          normal = {
            family = "FantasqueSansM Nerd Font Mono";
            style = "Regular";
          };
        };
      };
    };
  };
}

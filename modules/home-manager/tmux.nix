{ pkgs, ... }:
{
  programs.tmux = {
    enable = true;
    extraConfig = ''
      set-option -sa terminal-features ',xterm*:RGB'
      set -gq allow-passthrough on

      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      bind c new-window -c "#{pane_current_path}"

      bind -n S-Left select-pane -L
      bind -n S-Right select-pane -R
      bind -n S-Up select-pane -U
      bind -n S-Down select-pane -D

      bind-key -T copy-mode-vi v send-keys -X begin-selection

      bind-key x kill-pane

      set-option -g focus-events on
    '';
    escapeTime = 10;
    historyLimit = 10000;
    keyMode = "vi";
    mouse = true;
    newSession = true;
    plugins = with pkgs.tmuxPlugins; [
      resurrect
      {
        plugin = yank;
        extraConfig = ''
          set -g @shell_mode 'vi'
          set -g @yank_selection 'primary'
        '';
      }
      {
        plugin = catppuccin;
        extraConfig = ''
          set -g @catppuccin_flavor 'frappe'
          set -g @catppuccin_window_status_style "rounded"

          # Make the status line pretty and add some modules
          set -g status-right-length 100
          set -g status-left-length 100
          set -g status-left ""
          set -g status-right "#{E:@catppuccin_status_application}"
          set -agF status-right "#{E:@catppuccin_status_cpu}"
          set -ag status-right "#{E:@catppuccin_status_session}"
          set -ag status-right "#{E:@catppuccin_status_uptime}"
          set -agF status-right "#{E:@catppuccin_status_battery}"
        '';
      }
      cpu
      battery
    ];
    sensibleOnTop = false;
    shell = "${pkgs.zsh}/bin/zsh";
    prefix = "C-Space";
    terminal = "screen-256color";
    tmuxp.enable = true;
  };
}

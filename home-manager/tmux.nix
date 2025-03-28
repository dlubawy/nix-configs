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
    plugins = [
      pkgs.tmuxPlugins.resurrect
      {
        plugin = pkgs.tmuxPlugins.yank;
        extraConfig = ''
          set -g @shell_mode 'vi'
          set -g @yank_selection 'primary'
        '';
      }
      {
        plugin = pkgs.tmuxPlugins.catppuccin;
        extraConfig = ''
          set -g @catppuccin_flavor 'frappe'
        '';
      }
    ];
    sensibleOnTop = false;
    shell = "${pkgs.zsh}/bin/zsh";
    prefix = "C-Space";
    terminal = "screen-256color";
    tmuxp.enable = true;
  };
}

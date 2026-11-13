{ pkgs, ... }:

let
  c = {
    base = "#1e1e2e";
    mantle = "#181825";
    surface0 = "#313244";
    surface1 = "#45475a";
    overlay0 = "#6c7086";
    text = "#cdd6f4";
    mauve = "#cba6f7";
    blue = "#89b4fa";
    green = "#a6e3a1";
    peach = "#fab387";
    red = "#f38ba8";
  };

  sep = "";
in
{
  programs.tmux = {
    enable = true;
    prefix = "C-Space";
    baseIndex = 1;
    escapeTime = 0;
    keyMode = "vi";
    mouse = true;
    historyLimit = 50000;
    aggressiveResize = true;
    terminal = "tmux-256color";

    extraConfig = ''
      set -g set-titles on
      set -g set-titles-string "#W"

      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      bind c new-window -c "#{pane_current_path}"
      bind r source-file ~/.config/tmux/tmux.conf \; display "reloaded"

      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      set -as terminal-features ",xterm-kitty:RGB:usstyle:hyperlinks"
      set -g allow-passthrough on
      set -g renumber-windows on
      set -g focus-events on

      set -g pane-border-lines single
      set -g pane-border-status off
      set -g pane-border-indicators off

      set -g pane-border-style "fg=${c.surface1},bg=default"
      set -g pane-active-border-style "fg=${c.blue},bg=default"

      set -g status-style "bg=${c.mantle},fg=${c.overlay0}"
      set -g status-left "#[fg=${c.overlay0}] tmux · #S  "
      set -g status-right ""

      set -g window-status-separator " "
      set -g window-status-format "#[bg=${c.mantle},fg=${c.overlay0}] #I:#W "
      set -g window-status-current-format "#[bg=${c.surface0},fg=${c.blue},bold] #I:#W #[default]"
    '';
  };
}

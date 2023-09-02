{ pkgs, config, lib, mylib, ... }:

let
  inherit (lib.modules) mkIf;
  inherit (mylib) mkBoolOpt;

  #tmuxConfig = inputs.myconfig + /tmux;

  cfg = config.mymodules.programs.cli.tmux;
in
{
  options.mymodules.programs.cli.tmux = {
    enable = mkBoolOpt false;
    plugins = {
      catppuccin = {
        enable = mkBoolOpt true;
      };
    };
  };

  config.programs.tmux = mkIf cfg.enable {
    enable = true;
    baseIndex = 1;
    clock24 = true;
    aggressiveResize = true;
    customPaneNavigationAndResize = true;
    historyLimit = 100000;
    keyMode = "vi";

    mouse = true;

    sensibleOnTop = true;

    prefix = "C-a";
    shortcut = "a";

    shell = if config.mymodules.programs.cli.fish.enable then "${pkgs.fish}/bin/fish" else null;

    extraConfig = ''
      # Renumber windows sequentially after closing any of them
      set-option -g renumber-windows on

      # Fix titlebar
      set -g set-titles on
      set -g set-titles-string "#T"

      # Set working dir to cwd
      bind-key C-Space attach -c "#{pane_current_path}"

      # Fix colors
      set -g default-terminal "tmux-256color"
      set -ag terminal-overrides ",xterm-256color:RGB"

      # Resizing
      set -g window-size latest
    '';

    plugins = with pkgs; [
      (mkIf cfg.plugins.catppuccin.enable {
        plugin = tmuxPlugins.catppuccin;
        #plugin = catppuccinGit;
        extraConfig = ''
          # Theme
          #set -g @catppuccin_flavour "mocha"  # Latte, frappe, macchiato, mocha (default)

          # Window
          set -g @catppuccin_window_current_text "#{window_name}"
          set -g @catppuccin_window_default_text "#{window_name}"

          # Status icons
          set -g @catppuccin_window_status_enable "yes" # yes, no (default)
          #set -g @catppuccin_window_status_icon_enable "yes" # yes (default), no
          set -g @catppuccin_icon_window_last " "
          set -g @catppuccin_icon_window_current " "
          set -g @catppuccin_icon_window_zoom " "
          set -g @catppuccin_icon_window_mark "󰃀 "
          set -g @catppuccin_icon_window_silent "󰂠 "
          set -g @catppuccin_icon_window_activity "󱐋 "
          set -g @catppuccin_icon_window_bell "󰂞 "

          # Modules
          set -g @catppuccin_status_modules "directory session user host date_time"
          set -g @catppuccin_date_time_text "%d-%m %H:%M"

          # Seperators
          #set -g @catppuccin_window_left_separator "█"
          #set -g @catppuccin_window_middle_separator "█ "
          #set -g @catppuccin_window_right_separator "█"
          set -g @catppuccin_status_left_separator "█"
          #set -g @catppuccin_status_right_separator "█"
        '';

      })
    ];
  };

  #xdg.configFile."tmux/tmux.conf".source = tmuxConfig + "/tmux.conf";
  #xdg.configFile."tmux/theme.conf".source = tmuxConfig + "/theme.conf";
}

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
        enable = mkBoolOpt false;
      };
    };
  };

  config = mkIf cfg.enable {
    programs.tmux = {
      enable = true;
      baseIndex = 1;
      clock24 = true;
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

      '';

      plugins = with pkgs; [
        (mkIf cfg.plugins.catppuccin.enable {
          plugin = tmuxPlugins.catppuccin;
          extraConfig = ''
            #set -g @catppuccin_flavour "mocha"  # Latte, frappe, macchiato, mocha (default)

            set -g @catppuccin_date_time "%d-%m %H:%M"
            set -g @catppuccin_window_tabs_enabled on
            set -g @catppuccin_user "on"
            set -g @catppuccin_host "on"

            set -g @catppuccin_left_separator "█"
            set -g @catppuccin_right_separator "█"
          '';

        })
      ];
    };

    #xdg.configFile."tmux/tmux.conf".source = tmuxConfig + "/tmux.conf";
    #xdg.configFile."tmux/theme.conf".source = tmuxConfig + "/theme.conf";
  };
}

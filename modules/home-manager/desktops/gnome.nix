args@{ config, pkgs, lib, mylib, ... }:

let
  inherit (lib.attrsets) attrByPath;
  inherit (lib.modules) mkIf;
  inherit (mylib) mkBoolOpt;

  cfg = config.mymodules.desktops.gnome;
in
{
  options.mymodules.desktops.gnome = {
    enable = mkBoolOpt (attrByPath [ "systemConfig" "mymodules" "desktops" "gnome" "enable" ] false args);
  };

  config = mkIf cfg.enable {
    # https://github.com/gvolpe/dconf2nix
    dconf.settings = {
      "org/gnome/desktop/input-sources" = {
        xkb-options = [ "terminate:ctrl_alt_bksp" "caps:escape_shifted_capslock" ];
      };
      "org/gnome/desktop/interface" = {
        clock-show-weekday = true;
        color-scheme = "prefer-dark";
        enable-animations = false;
        show-battery-percentage = true;
        monospace-font-name = "IosevkaTerm Nerd Font 10";
      };
      "org/gnome/desktop/peripherals/touchpad" = {
        tap-to-click = true;
        two-finger-scrolling-enabled = true;
        speed = 0.50000000000000000;
      };
      "org/gnome/desktop/search-providers" = {
        disable-external = false;
      };
      "org/gnome/desktop/wm/preferences" = {
        action-middle-click-titlebar = "minimize";
        button-layout = "appmenu:minimize,maximize,close";
        num-workspaces = 4;
        resize-with-right-button = true;
      };
      "org/gnome/desktop/wm/keybindings" = {
        switch-to-workspace-1 = [ "<Super>1" ];
        switch-to-workspace-2 = [ "<Super>2" ];
        switch-to-workspace-3 = [ "<Super>3" ];
        switch-to-workspace-4 = [ "<Super>4" ];

        move-to-workspace-1 = [ "<Shift><Super>1" ];
        move-to-workspace-2 = [ "<Shift><Super>2" ];
        move-to-workspace-3 = [ "<Shift><Super>3" ];
        move-to-workspace-4 = [ "<Shift><Super>4" ];
      };
      "org/gnome/mutter" = {
        dynamic-workspaces = false;
        edge-tiling = true;
      };
      "org/gnome/settings-daemon/plugins/color" = {
        night-light-enabled = true;
      };
      "org/gnome/settings-daemon/plugins/media-keys" = {
        custom-keybindings = [
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/launch-terminal/"
        ];
      };
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/launch-terminal" = {
        binding = "<Super>Return";
        command = "/run/current-system/sw/bin/kgx";
        name = "Launch terminal";
      };
      "org/gnome/shell" = {
        favorite-apps = [ ];
        disable-user-extensions = false;

        enabled-extensions = [
          # builtins
          "auto-move-windows@gnome-shell-extensions.gcampax.github.com"
          "native-window-placement@gnome-shell-extensions.gcampax.github.com"
          "workspace-indicator@gnome-shell-extensions.gcampax.github.com"

          # extra
          "just-perfection-desktop@just-perfection"
          "appindicatorsupport@rgcjonas.gmail.com"
        ];
        disabled-extensions = [ ];
      };
      "org/gnome/shell/app-switcher" = {
        current-workspace-only = true;
      };
      "org/gnome/shell/extensions/auto-move-windows" = {
        application-list = [
          "com.discordapp.Discord.desktop:4"
          "com.spotify.Client.desktop:4"
          "spotify.desktop:4"
        ];
      };
      "org/gnome/shell/extensions/just-perfection" = {
        accessibility-menu = false;
        animation = 0;
        app-menu = true;
        app-menu-icon = false;
        dash-icon-size = 32;
        hot-corner = true;
        notification-banner-position = 5;
        panel = false;
        panel-arrow = false;
        panel-corner-size = 1;
        panel-in-overview = true;
        ripple-box = false;
        search = false;
        show-apps-button = true;
        startup-status = 0;
        theme = true;
        window-demands-attention-focus = true;
        window-picker-icon = false;
        workspace = false;
        workspace-switcher-should-show = false;
        workspaces-in-app-grid = false;
      };
      "org/gnome/shell/keybindings" = {
        switch-to-application-1 = [ ];
        switch-to-application-2 = [ ];
        switch-to-application-3 = [ ];
        switch-to-application-4 = [ ];
      };
    };

    # gnome extensions
    home.packages = with pkgs; [
      gnome.gnome-tweaks

      # Extensions
      ## Builtin
      gnomeExtensions.auto-move-windows
      gnomeExtensions.native-window-placement
      gnomeExtensions.workspace-indicator

      ## Extra
      gnomeExtensions.just-perfection
      gnomeExtensions.appindicator
    ];

  };
}

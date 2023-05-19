args@{ config, options, pkgs, lib, mylib, ... }:

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
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        enable-animations = false;
      };
      "org/gnome/desktop/peripherals/touchpad" = {
        tap-to-click = true;
        two-finger-scrolling-enabled = true;
      };
      "org/gnome/desktop/wm/preferences" = {
        num-workspaces = 4;
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
      };
      "org/gnome/settings-daemon/plugins/color" = {
        night-light-enabled = true;
      };
      "org/gnome/shell" = {
        disable-user-extensions = false;

        enabled-extensions = [
          # builtins
          "auto-move-windows@gnome-shell-extensions.gcampax.github.com"
          "native-window-placement@gnome-shell-extensions.gcampax.github.com"
          "workspace-indicator@gnome-shell-extensions.gcampax.github.com"

          # extra
          "just-perfection-desktop@just-perfection"
        ];
        disabled-extensions = [ ];
      };
      "org/gnome/shell/extensions/just-perfection" = {
        accessibility-menu = false;
        animations = 0;
        app-menu = true;
        app-menu-icon = false;
        dash-icon-size = 32;
        hot-corner = true;
        panel = false;
        panel-arrow = false;
        panel-corner-size = 1;
        panel-in-overview = true;
        ripple-box = false;
        search = false;
        show-apps-button = false;
        startup-status = 0;
        theme = true;
        window-demands-attention-focus = true;
        window-picker-icon = false;
        workspace = false;
        workspace-switcher-should-show = false;
        workspaces-in-app-grid = false;
      };
    };

    # gnome extensions
    home.packages = with pkgs.gnomeExtensions; [
      auto-move-windows
      native-window-placement
      workspace-indicator
      just-perfection
    ];
  };
}


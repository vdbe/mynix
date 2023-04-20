{ config, options, lib, mylib, ... }:

let
  inherit (lib.modules) mkIf mkDefault;
  inherit (mylib) mkBoolOpt;

  cfg = config.modules.desktops.gnome;
in
{
  options.modules.desktops.gnome = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    modules = {
      services = {
        xserver.enable = mkDefault true;
        displayManager.gdm.enable = mkDefault true;
      };
    };

    services.xserver.desktopManager.gnome.enable = true;
  };
}


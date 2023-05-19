{ config, options, lib, mylib, ... }:

let
  inherit (lib.modules) mkIf mkDefault;
  inherit (mylib) mkBoolOpt;

  cfg = config.mymodules.desktops.gnome;
in
{
  options.mymodules.desktops.gnome = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    mymodules = {
      services = {
        xserver.enable = mkDefault true;
        displayManager.gdm.enable = mkDefault true;
      };
    };

    services.xserver.desktopManager.gnome.enable = true;
  };
}


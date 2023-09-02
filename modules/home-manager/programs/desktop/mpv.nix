{ config, lib, mylib, pkgs, ... }:

let
  inherit (lib) lists;
  inherit (lib.modules) mkIf;
  inherit (mylib) mkBoolOpt;


  cfg = config.mymodules.programs.desktop.mpv;
in
{
  options.mymodules.programs.desktop.mpv = {
    enable = mkBoolOpt false;
  };

  config.programs.mpv = mkIf cfg.enable {
    enable = true;

    scripts = with pkgs.mpvScripts; [
      mpris
      uosc
      thumbfast
    ] ++ lists.optional config.mymodules.desktops.gnome.enable inhibit-gnome;

    config = {
      # UOSC script
      osc = false; # required so that the 2 UIs don't fight each other
      osd-bar = false; # uosc provides its own seeking/volume indicators, so you also don't need this
      border = false; # uosc will draw its own window controls if you disable window border
    };
  };
}

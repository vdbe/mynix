{ config, lib, mylib, ... }:

let
  inherit (lib.modules) mkIf;
  inherit (mylib) mkBoolOpt;


  cfg = config.mymodules.programs.desktop.mpv;
in
{
  options.mymodules.programs.desktop.mpv = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    programs.mpv = {
      enable = true;
    };
  };
}

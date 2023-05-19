{ config, options, lib, mylib, ... }:

let
  inherit (lib.modules) mkIf mkDefault;
  inherit (mylib) mkBoolOpt;

  cfg = config.mymodules.services.displayManager.gdm;
in
{
  options.mymodules.services.displayManager.gdm = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    services.xserver.displayManager.gdm.enable = mkDefault true;
  };
}


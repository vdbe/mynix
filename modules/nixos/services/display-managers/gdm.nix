{ config, options, lib, mylib, ... }:

let
  inherit (lib.modules) mkIf mkDefault;
  inherit (mylib) mkBoolOpt;

  cfg = config.modules.services.displayManager.gdm;
in
{
  options.modules.services.displayManager.gdm = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    services.xserver.displayManager.gdm.enable = mkDefault true;
  };
}


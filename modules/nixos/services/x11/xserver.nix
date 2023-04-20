{ config, options, lib, mylib, ... }:

let
  inherit (lib.modules) mkIf mkDefault;
  inherit (mylib) mkBoolOpt;

  cfg = config.modules.services.xserver;
in
{
  options.modules.services.xserver = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    services.xserver.enable = mkDefault true;
  };
}


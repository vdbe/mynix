{ config, options, lib, mylib, ... }:

let
  inherit (lib.modules) mkIf;
  inherit (mylib) mkBoolOpt;

  cfg = config.mymodules.services.xe-guest-utilities;
in
{
  options.mymodules.services.xe-guest-utilities = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    services.xe-guest-utilities = {
      enable = true;
    };
  };
}


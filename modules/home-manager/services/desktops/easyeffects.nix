{ config, lib, mylib, ... }:

let
  inherit (lib.modules) mkIf;
  inherit (mylib) mkBoolOpt;

  cfg = config.mymodules.services.easyeffects;
in
{
  options.mymodules.services.easyeffects = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    services.easyeffects = {
      enable = true;
    };
    mymodules.impermanence = {
      data.directories = [
        ".config/easyeffects"
      ];
    };
  };
}

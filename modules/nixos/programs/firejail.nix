{ config, lib, mylib, ... }:

let
  inherit (lib.modules) mkIf;
  inherit (mylib) mkBoolOpt;

  cfg = config.mymodules.programs.firejail;
in
{
  options.mymodules.programs.firejail = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    programs.firejail.enable = true;
  };
}

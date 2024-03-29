{ config, lib, mylib, ... }:

let
  inherit (lib) mkIf;
  inherit (mylib) mkBoolOpt;

  cfg = config.mymodules.programs.cli.translate;
in
{
  options.mymodules.programs.cli.translate = {
    enable = mkBoolOpt false;
  };

  config.programs.translate-shell = mkIf cfg.enable {
    enable = true;
  };
}

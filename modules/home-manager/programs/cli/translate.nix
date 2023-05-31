{ config, options, lib, mylib, ... }:

let
  inherit (lib) mkIf;
  inherit (mylib) mkBoolOpt;

  cfg = config.mymodules.programs.cli.translate;
in
{
  options.mymodules.programs.cli.translate = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    programs.translate-shell.enable = true;
  };
}


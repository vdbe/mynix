{ config, options, lib, mylib, ... }:

let
  inherit (lib) mkIf;
  inherit (mylib) mkBoolOpt;

  cfg = config.mymodules.programs.cli.starship;
in
{
  options.mymodules.programs.cli.starship = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    programs.starship = {
      enable = true;
    };
  };
}


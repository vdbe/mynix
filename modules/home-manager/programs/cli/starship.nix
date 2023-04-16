{ config, options, lib, mylib, ... }:

let
  inherit (lib) mkIf;
  inherit (mylib) mkBoolOpt;

  cfg = config.modules.programs.cli.starship;
in
{
  options.modules.programs.cli.starship = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    programs.starship = {
      enable = true;
    };
  };
}


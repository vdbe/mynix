{ config, options, lib, mylib, ... }:

let
  inherit (lib.modules) mkIf;
  inherit (mylib) mkBoolOpt;

  cfg = config.modules.programs.cli.fish;
in
{
  options.modules.programs.cli.fish = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    programs.fish = {
      enable = true;
    };
  };
}


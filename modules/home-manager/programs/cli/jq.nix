{ config, options, lib, mylib, ... }:

let
  inherit (lib) mkIf;
  inherit (mylib) mkBoolOpt;

  cfg = config.mymodules.programs.cli.jq;
in
{
  options.mymodules.programs.cli.jq = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    programs.jq.enable = true;
  };
}


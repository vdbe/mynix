{ config, lib, mylib, ... }:

let
  inherit (lib) mkIf;
  inherit (mylib) mkBoolOpt;

  cfg = config.mymodules.programs.cli.jq;
in
{
  options.mymodules.programs.cli.jq = {
    enable = mkBoolOpt false;
  };

  config.programs.jq = mkIf cfg.enable {
    enable = true;
  };
}

{ config, options, lib, mylib, ... }:

let
  inherit (lib) mkIf;
  inherit (mylib) mkBoolOpt;

  cfg = config.mymodules.programs.cli.password-store;
in
{
  options.mymodules.programs.cli.password-store = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    programs.password-store.enable = true;
  };
}


{ config, options, lib, mylib, ... }:

let
  inherit (lib) mkIf;
  inherit (mylib) mkBoolOpt;

  cfg = config.mymodules.programs.cli.lazygit;
in
{
  options.mymodules.programs.cli.lazygit = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    programs.lazygit.enable = true;
  };
}


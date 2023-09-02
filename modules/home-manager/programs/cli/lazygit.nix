{ config, lib, mylib, ... }:

let
  inherit (lib) mkIf;
  inherit (mylib) mkBoolOpt;

  cfg = config.mymodules.programs.cli.lazygit;
in
{
  options.mymodules.programs.cli.lazygit = {
    enable = mkBoolOpt false;
  };

  config.programs.lazygit = mkIf cfg.enable {
    enable = true;
  };
}

{ config, lib, mylib, ... }:

let
  inherit (lib.modules) mkIf;
  inherit (mylib) mkBoolOpt;

  cfg = config.mymodules.programs.cli.bash;
in
{
  options.mymodules.programs.cli.bash = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    # No longer has any effect is jsut for systemConfig in home-manager
    #programs.bash = {
    #  enable = true;
    #};
  };
}

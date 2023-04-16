{ config, options, lib, mylib, ... }:

let
  inherit (lib.modules) mkIf;
  inherit (mylib) mkBoolOpt;

  cfg = config.modules.programs.cli.bash;
in
{
  options.modules.programs.cli.bash = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    programs.bash = {
      enable = true;
    };
  };
}


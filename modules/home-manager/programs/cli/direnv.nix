{ config, options, lib, mylib, ... }:

let
  inherit (lib) mkIf;
  inherit (mylib) mkBoolOpt;

  cfg = config.mymodules.programs.cli.direnv;
in
{
  options.mymodules.programs.cli.direnv = {
    enable = mkBoolOpt false;

    nix-direnv = {
      enable = mkBoolOpt true;
    };
  };

  config = mkIf cfg.enable {
    programs.direnv = {
      enable = true;

      nix-direnv.enable = cfg.nix-direnv.enable;
    };
  };
}


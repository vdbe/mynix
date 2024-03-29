{ config, lib, mylib, ... }:

let
  inherit (lib.modules) mkIf;

  inherit (mylib) mkBoolOpt;

  cfg = config.mymodules.programs.cli.starship;
in
{
  options.mymodules.programs.cli.starship = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    programs.starship = {
      enable = true;
    };

    mymodules.impermanence.cache.directories = [
      ".cache/starship"
    ];
  };
}

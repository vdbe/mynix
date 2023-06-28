{ config, options, lib, mylib, ... }:

let
  inherit (lib) mkIf mkMerge;
  inherit (mylib) mkBoolOpt;

  inherit (config.mymodules) impermanence;

  cfg = config.mymodules.programs.cli.starship;
in
{
  options.mymodules.programs.cli.starship = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable (mkMerge [
    {
      programs.starship = {
        enable = true;
      };
    }

    (mkIf impermanence.enable {
      home.persistence."${impermanence.location}/cache/users/${config.home.username}" = {
        directories = [
          ".cache/starship"
        ];
        allowOther = true;
        removePrefixDirectory = false;
      };
    })
  ]);
}


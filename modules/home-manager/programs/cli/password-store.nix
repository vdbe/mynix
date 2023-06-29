{ config, lib, mylib, ... }:

let
  inherit (lib.modules) mkIf mkMerge;
  inherit (mylib) mkBoolOpt;

  inherit (config.mymodules) impermanence;

  cfg = config.mymodules.programs.cli.password-store;
in
{
  options.mymodules.programs.cli.password-store = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable (mkMerge [
    {
      programs.password-store.enable = true;
    }

    (mkIf impermanence.enable {
      home.persistence."${impermanence.location}/data/users/${config.home.username}" = {
        removePrefixDirectory = false;
        allowOther = true;
        directories = [
          ".local/share/password-store"
        ];
      };
    })
  ]);
}

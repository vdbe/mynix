{ config, lib, mylib, pkgs, ... }:

let
  inherit (lib.modules) mkIf mkMerge;
  inherit (mylib) mkBoolOpt;

  inherit (config.mymodules) impermanence;

  cfg = config.mymodules.programs.desktop.bitwarden;
in
{
  options.mymodules.programs.desktop.bitwarden = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable
    (mkMerge [
      {
        mymodules.programs.cli.bitwarden-cli.enable = true;

        home.packages = with pkgs; [ bitwarden ];
      }
      (mkIf impermanence.enable {
        home.persistence."${impermanence.location}/state/users/${config.home.username}" = {
          removePrefixDirectory = false;
          allowOther = true;
          directories = [
            ".config/Bitwarden"
          ];
        };

      })
    ]);
}

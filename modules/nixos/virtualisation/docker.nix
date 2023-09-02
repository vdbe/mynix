{ config, lib, mylib, ... }:

let
  inherit (lib.modules) mkIf mkMerge;
  inherit (mylib) mkBoolOpt;

  inherit (config.mymodules) impermanence;

  cfg = config.mymodules.virtualisation.docker;
in
{
  options.mymodules.virtualisation.docker = {
    enable = mkBoolOpt false;
    autoPrune = mkBoolOpt true;
    enableOnBoot = mkBoolOpt false;
  };

  config = mkIf cfg.enable (mkMerge [
    {
      virtualisation.docker = {
        enable = true;
        inherit (cfg) enableOnBoot;
        autoPrune = {
          enable = cfg.autoPrune;
        };
      };
    }

    (mkIf impermanence.enable {
      environment.persistence."${impermanence.location}/state/system" = {
        inherit (impermanence) hideMounts;
        directories = [
          "/var/lib/docker"
        ];
      };
    })
  ]);
}

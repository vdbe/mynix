{ config, options, lib, mylib, ... }:

let
  inherit (lib.modules) mkIf mkDefault mkMerge;
  inherit (mylib) mkBoolOpt;

  inherit (config.mymodules) impermanence;

  cfg = config.mymodules.services.flatpak;
in
{
  options.mymodules.services.flatpak = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable (mkMerge [
    {
      services.flatpak.enable = mkDefault true;
      xdg.portal.enable = mkDefault true;
    }
    (mkIf impermanence.enable {
      environment.persistence."${impermanence.location}/state/system" = {
        inherit (impermanence) hideMounts;
        directories = [
          "/var/lib/flatpak"
        ];
      };
    })
  ]);
}


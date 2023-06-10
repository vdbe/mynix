{ config, options, lib, mylib, ... }:

let
  inherit (lib.modules) mkIf mkDefault mkMerge;
  inherit (mylib) mkBoolOpt;

  inherit (config.mymodules) impermanence;

  cfg = config.mymodules.desktops.gnome;
in
{
  options.mymodules.desktops.gnome = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable (mkMerge [
    {
      mymodules = {
        services = {
          xserver.enable = mkDefault true;
          displayManager.gdm.enable = mkDefault true;
        };
      };

      services.xserver.desktopManager.gnome = {
        enable = true;
      };

      services.gnome = {
        gnome-initial-setup.enable = false;
      };
    }
    (mkIf impermanence.enable {
      environment.persistence."${impermanence.location}/data/system" = {
        inherit (impermanence) hideMounts;
        directories = [
          "/etc/NetworkManager/system-connections"
          "/var/lib/bluetooth"
        ];
      };
    })
  ]);
}


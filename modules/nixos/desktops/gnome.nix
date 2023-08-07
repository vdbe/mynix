{ config, lib, mylib, pkgs, ... }:

let
  inherit (lib.modules) mkIf mkDefault mkMerge mkForce;
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
          pipewire.enable = true;
        };
      };

      services = {
        xserver.desktopManager.gnome = {
          enable = true;
        };
        gnome = {
          gnome-initial-setup.enable = false;
          gnome-keyring.enable = mkForce false;
        };
      };

      environment.gnome.excludePackages = with pkgs; [ gnome-tour folks ];
      programs.evolution.enable = false;

    }
    (mkIf impermanence.enable {
      environment.persistence."${impermanence.location}/state/system" = {
        inherit (impermanence) hideMounts;
        directories = [
          "/etc/NetworkManager/system-connections"
          #"/etc/NetworkManager/VPN"
          "/var/lib/bluetooth"

        ];
      };
    })
  ]);
}

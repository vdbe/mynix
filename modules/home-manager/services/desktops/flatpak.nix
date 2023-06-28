args@{ config, options, lib, mylib, ... }:

let
  inherit (lib.attrsets) attrByPath;
  inherit (lib.modules) mkIf mkMerge;
  inherit (mylib) mkBoolOpt;

  inherit (config.mymodules) impermanence;

  cfg = config.mymodules.services.flatpak;
in
{
  options.mymodules.services.flatpak = {
    enable = mkBoolOpt (attrByPath [ "systemConfig" "mymodules" "services" "flatpak" "enable" ] false args);
  };

  config = mkIf cfg.enable (mkMerge [
    { }
    (mkIf impermanence.enable {
      home.persistence."${impermanence.location}/cache/users/${config.home.username}" = {
        removePrefixDirectory = false;
        allowOther = true;
        directories = [
          ".cache/flatpak"
        ];
      };
      home.persistence."${impermanence.location}/state/users/${config.home.username}" = {
        removePrefixDirectory = false;
        allowOther = true;
        directories = [
          ".local/share/flatpak"
          ".var" # contains cache, config and data for a flatpak
        ];
      };
    })
  ]);
}

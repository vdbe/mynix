args@{ config, lib, mylib, ... }:

let
  inherit (lib.attrsets) attrByPath;
  inherit (lib.modules) mkIf;
  inherit (mylib) mkBoolOpt;

  cfg = config.mymodules.services.flatpak;
in
{
  options.mymodules.services.flatpak = {
    enable = mkBoolOpt (attrByPath [ "systemConfig" "mymodules" "services" "flatpak" "enable" ] false args);
  };

  config.mymodules.impermanence = mkIf cfg.enable {
    state.directories = [
      ".local/share/flatpak"
      ".var" # contains cache, config and data for a flatpak
    ];
    cache.directories = [
      ".cache/flatpak"
    ];
  };
}

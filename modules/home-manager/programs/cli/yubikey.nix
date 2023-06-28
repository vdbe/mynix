args@{ config, options, lib, mylib, pkgs, ... }:

let
  inherit (lib.attrsets) attrByPath;
  inherit (lib.modules) mkIf;
  inherit (mylib) mkBoolOpt;


  cfg = config.mymodules.programs.cli.yubikey;
in
{
  options.mymodules.programs.cli.yubikey = {
    enable = mkBoolOpt (attrByPath [ "systemConfig" "mymodules" "yubikey" "enable" ] false args);
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      yubikey-manager
      yubikey-personalization
    ];
  };
}


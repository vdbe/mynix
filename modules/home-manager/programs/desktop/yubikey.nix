{ config, options, lib, mylib, pkgs, ... }:

let
  inherit (lib.modules) mkIf;
  inherit (mylib) mkBoolOpt;


  cfg = config.mymodules.programs.desktop.yubikey;
in
{
  options.mymodules.programs.desktop.yubikey = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      yubikey-personalization-gui
      yubioath-flutter
    ];
  };
}


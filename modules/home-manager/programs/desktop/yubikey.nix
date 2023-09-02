{ config, lib, mylib, pkgs, ... }:

let
  inherit (lib.modules) mkIf;
  inherit (mylib) mkBoolOpt;


  cfg = config.mymodules.programs.desktop.yubikey;
in
{
  options.mymodules.programs.desktop.yubikey = {
    enable = mkBoolOpt false;
  };

  config.home.packages = mkIf cfg.enable (with pkgs; [
    yubikey-personalization-gui
    yubioath-flutter
  ]);
}

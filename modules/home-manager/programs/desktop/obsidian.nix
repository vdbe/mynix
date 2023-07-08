{ config, lib, mylib, pkgs, ... }:

let
  inherit (lib.modules) mkIf;
  inherit (mylib) mkBoolOpt;


  cfg = config.mymodules.programs.desktop.obsidian;
in
{
  options.mymodules.programs.desktop.obsidian = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      obsidian
    ];

    mymodules.impermanence.data.directories = [
      ".config/obsidian"
    ];
  };
}

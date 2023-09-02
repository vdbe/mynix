{ config, lib, mylib, pkgs, ... }:

let
  inherit (lib.modules) mkIf;
  inherit (mylib) mkBoolOpt;

  cfg = config.mymodules.programs.desktop.bitwarden;
in
{
  options.mymodules.programs.desktop.bitwarden = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    mymodules = {
      programs.cli.bitwarden-cli.enable = true;
      impermanence.state.directories = [
        ".config/Bitwarden"
      ];
    };

    home.packages = with pkgs; [ bitwarden ];
  }
  ;
}

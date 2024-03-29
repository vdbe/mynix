{ config, lib, mylib, pkgs, ... }:

let
  inherit (lib.modules) mkIf;
  inherit (mylib) mkBoolOpt;

  cfg = config.mymodules.programs.cli.bitwarden-cli;
in
{
  options.mymodules.programs.cli.bitwarden-cli = {
    enable = mkBoolOpt false;
  };

  config.home.packages = mkIf cfg.enable (with pkgs; [ bitwarden-cli ]);
}

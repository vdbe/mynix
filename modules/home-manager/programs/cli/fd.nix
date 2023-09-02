{ config, lib, mylib, pkgs, ... }:

let
  inherit (lib) mkIf;
  inherit (mylib) mkBoolOpt;

  cfg = config.mymodules.programs.cli.fd;
in
{
  options.mymodules.programs.cli.fd = {
    enable = mkBoolOpt false;
  };

  config.home.packages = mkIf cfg.enable (with pkgs; [ fd ]);
}

{ config, options, lib, mylib, pkgs, ... }:

let
  inherit (lib) mkIf;
  inherit (mylib) mkBoolOpt;

  cfg = config.mymodules.programs.cli.fd;
in
{
  options.mymodules.programs.cli.fd = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      fd
    ];
  };
}


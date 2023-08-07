{ config, lib, mylib, pkgs, ... }:

let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkPackageOption;
  inherit (mylib) mkBoolOpt;

  cfg = config.mymodules.programs.cli.tldr;
in
{
  options.mymodules.programs.cli.tldr = {
    enable = mkBoolOpt false;
    package = mkPackageOption pkgs "tldr" { };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}

{ config, options, lib, mylib, pkgs, ... }:

let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkPackageOption;
  inherit (mylib) mkBoolOpt;

  cfg = config.mymodules.programs.cli.ripgrep;
in
{
  options.mymodules.programs.cli.ripgrep = {
    enable = mkBoolOpt false;
    package = mkPackageOption pkgs "ripgrep" { };
  };

  config = mkIf cfg.enable {
    # TODO: Not yet supported in 23.05
    # programs.ripgrep = {
    #   inherit (cfg) package;
    #   enable = true;
    # };

    home.packages = [ cfg.package ];
  };
}


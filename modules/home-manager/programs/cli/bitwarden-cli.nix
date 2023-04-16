{ config, options, lib, mylib, pkgs, ... }:

let
  inherit (lib.modules) mkIf;
  inherit (mylib) mkBoolOpt;

  cfg = config.modules.programs.cli.bitwarden-cli;
in
{
  options.modules.programs.cli.bitwarden-cli = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ unstable.bitwarden-cli ];
  };
}

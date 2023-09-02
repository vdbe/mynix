{ config, lib, mylib, ... }:

let
  inherit (lib.modules) mkIf;
  inherit (mylib) mkBoolOpt;


  cfg = config.mymodules.services.gpg-agent;
in
{
  options.mymodules.services.gpg-agent = {
    enable = mkBoolOpt false;
    enableSshSupport = mkBoolOpt false;

  };

  config.services.gpg-agent = mkIf cfg.enable {
    enable = true;
    inherit (cfg) enableSshSupport;
  };
}

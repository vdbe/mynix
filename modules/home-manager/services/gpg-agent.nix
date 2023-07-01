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

  config = mkIf cfg.enable {
    services.gpg-agent = {
      enable = true;
      inherit (cfg) enableSshSupport;
    };
  };
}

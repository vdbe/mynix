{ config, options, lib, mylib, ... }:

let
  inherit (lib.modules) mkIf;
  inherit (mylib) mkBoolOpt;
  cfg = config.modules.services.gpg-agent;
in
{
  options.modules.services.gpg-agent = {
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

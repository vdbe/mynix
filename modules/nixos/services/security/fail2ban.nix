{ config, lib, mylib, ... }:

let
  inherit (lib.modules) mkIf;
  inherit (mylib) mkBoolOpt;

  cfg = config.mymodules.services.fail2ban;
in
{
  options.mymodules.services.fail2ban = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    services.fail2ban = {
      enable = true;
      #ignoreIP = [ "127.0.0.1/16" "192.168.1.0/24" ];
      bantime-increment = {
        enable = true;
        maxtime = "168h";
        overalljails = true;
      };
    };
  };
}

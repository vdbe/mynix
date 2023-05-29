{ config, lib, mylib, ... }:

let
  inherit (lib.modules) mkIf;
  inherit (mylib) mkBoolOpt;
  cfg = config.mymodules.services.openssh;
in
{
  options.mymodules.services.openssh = {
    enable = mkBoolOpt true;
  };

  config = mkIf cfg.enable {
    services.openssh = {
      enable = true;
      openFirewall = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = true;
      };
      startWhenNeeded = true;
      extraConfig = ''
        StreamLocalBindUnlink yes
      '';
      #ports = [ 9999 ];
    };
  };
}

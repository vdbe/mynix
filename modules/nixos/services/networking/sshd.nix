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
      # stateVersion: 23.05
      #settings = {
      #  PermitRootLogin = "no";
      #  PasswordAuthentication = true;
      #};
      permitRootLogin = "no";
      passwordAuthentication = true;
      startWhenNeeded = true;
      extraConfig = ''
        StreamLocalBindUnlink yes
      '';
      #ports = [ 9999 ];
    };
  };
}

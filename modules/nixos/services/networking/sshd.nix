{ config, lib, mylib, ... }:

let
  inherit (lib) types;
  inherit (lib.modules) mkIf mkDefault;
  inherit (lib.options) mkOption;
  inherit (mylib) mkBoolOpt;
  cfg = config.mymodules.services.openssh;
in
{
  options.mymodules.services.openssh = {
    enable = mkBoolOpt true;

    settings = {
      PermitRootLogin = mkOption {
        default = "prohibit-password";
        type = types.enum [ "yes" "without-password" "prohibit-password" "forced-commands-only" "no" ];
        description = lib.mdDoc ''
          Whether the root user can login using ssh.
        '';
      };
      PasswordAuthentication = mkBoolOpt false;
    };
  };

  config = mkIf cfg.enable {
    services.openssh = {
      enable = true;
      openFirewall = true;
      settings = {
        PermitRootLogin = mkDefault cfg.settings.PermitRootLogin;
        PasswordAuthentication = mkDefault cfg.settings.PasswordAuthentication;
      };
      startWhenNeeded = true;
      extraConfig = ''
        StreamLocalBindUnlink yes
      '';
      #ports = [ 9999 ];
    };
  };
}

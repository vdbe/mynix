{ options, config, lib, mylib, ... }:

let
  inherit (lib.modules) mkDefault mkIf;
  inherit (mylib) mkBoolOpt;

  cfg = config.modules.yubikey;
in
{
  options.modules.yubikey = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    modules.services.pcscd.enable = mkDefault true;
  };
}

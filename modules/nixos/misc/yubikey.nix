{ options, config, lib, mylib, ... }:

let
  inherit (lib.modules) mkDefault mkIf;
  inherit (mylib) mkBoolOpt;

  cfg = config.mymodules.yubikey;
in
{
  options.mymodules.yubikey = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    mymodules.services.pcscd.enable = mkDefault true;
  };
}

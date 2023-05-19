{ options, config, lib, mylib, ... }:

let
  inherit (lib.modules) mkIf;
  inherit (mylib) mkBoolOpt;

  cfg = config.mymodules.services.pcscd;
in
{
  options.mymodules.services.pcscd = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    services.pcscd.enable = true;
  };
}

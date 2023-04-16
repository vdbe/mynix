{ options, config, lib, mylib, ... }:

let
  inherit (lib.modules) mkIf;
  inherit (mylib) mkBoolOpt;

  cfg = config.modules.services.pcscd;
in
{
  options.modules.services.pcscd = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    services.pcscd.enable = true;
  };
}

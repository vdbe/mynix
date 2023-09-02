#{ config, lib, mylib, ... }:
#
#let
#  inherit (lib.modules) mkIf;
#  inherit (mylib) mkBoolOpt;
#
#  cfg = config.mymodules.services.prometheus;
#in
#{
#  options.mymodules.services.pcscd = {
#    enable = mkBoolOpt false;
#    logging
#  };
#
#  config = mkIf cfg.enable {
#    services.pcscd.enable = true;
#  };
#}
_: { }

{ options, config, lib, mylib, ... }:

let
  inherit (lib.modules) mkIf;
  inherit (mylib) mkBoolOpt;

  cfg = config.mymodules.security.acme;
in
{
  options.mymodules.security.acme = {
    enable = mkBoolOpt false;

    #defaults = options.security.acme.defaults;
  };

  config = mkIf cfg.enable {
    #security.acme = {
    #  acceptTerms = true;

    #  defaults = {
    #    inherit (cfg.default) dnsProvider credentialsFile;
    #  };
    #};
  };
}

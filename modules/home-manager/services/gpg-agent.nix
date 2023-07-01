{ config, lib, mylib, ... }:

let
  inherit (lib.modules) mkIf mkMerge;
  inherit (mylib) mkBoolOpt;

  inherit (config.mymodules) impermanence;

  cfg = config.mymodules.services.gpg-agent;
in
{
  options.mymodules.services.gpg-agent = {
    enable = mkBoolOpt false;
    enableSshSupport = mkBoolOpt false;

  };

  config = mkIf cfg.enable (mkMerge [
    {
      services.gpg-agent = {
        enable = true;
        inherit (cfg) enableSshSupport;
      };
    }

    (mkIf impermanence.enable {
      # NOTE: Maybe state?
      home.persistence."${impermanence.location}/cache/users/${config.home.username}" = {
        removePrefixDirectory = false;
        allowOther = true;
        directories = [
          #".gnupg/private-keys-v1.d"
        ];
      };
    })
  ]);
}

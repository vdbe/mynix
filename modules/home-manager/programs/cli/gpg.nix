{ config, options, lib, mylib, myconfig, ... }:

let
  inherit (lib.modules) mkDefault mkIf;
  inherit (mylib) mkBoolOpt;

  gpgKeySource = myconfig + "/gpg/pub.key";

  cfg = config.mymodules.programs.cli.gpg;
in
{
  options.mymodules.programs.cli.gpg = {
    enable = mkBoolOpt false;
    mutableKeys = mkBoolOpt false;
    mutableTrust = mkBoolOpt false;

    # TODO: Option to provide key or to not import key
    # TODO: enableAgent/useAgent options
    # TODO: https://search.nixos.org/options?channel=22.11&show=hardware.gpgSmartcards.enable&from=0&size=50&sort=relevance&type=packages&query=gpg+use-agent
  };

  config = mkIf cfg.enable {
    programs.gpg = {
      enable = mkDefault true;
      inherit (cfg) mutableKeys mutableTrust;
      publicKeys = [
        {
          source = gpgKeySource;
          trust = "ultimate";
        }
      ];
    };

    mymodules.services.gpg-agent.enable = config.programs.gpg.enable;
  };
}

{ config, options, lib, mylib, inputs, ... }:

let
  inherit (lib.modules) mkDefault mkIf;
  inherit (mylib) mkBoolOpt;

  gpgKeySource = inputs.myconfig + /gpg/pub.key;

  cfg = config.modules.programs.cli.gpg;
in
{
  options.modules.programs.cli.gpg = {
    enable = mkBoolOpt false;

    # TODO: Option to provide key or to not import key
    # TODO: enableAgent/useAgent options
    # TODO: https://search.nixos.org/options?channel=22.11&show=hardware.gpgSmartcards.enable&from=0&size=50&sort=relevance&type=packages&query=gpg+use-agent
  };

  config = mkIf cfg.enable {
    programs.gpg = {
      enable = true;
      mutableKeys = false;
      mutableTrust = false;
      publicKeys = [
        {
          source = gpgKeySource;
          trust = "ultimate";
        }
      ];
    };

    modules.services.gpg-agent.enable = mkDefault true;
  };
}

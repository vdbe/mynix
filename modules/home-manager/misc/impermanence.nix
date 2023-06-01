args@{ config, options, lib, mylib, inputs, ... }:

let
  inherit (lib) types;
  inherit (lib.attrsets) attrByPath;
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkOption;
  inherit (mylib) mkBoolOpt;

  systemImpermanence = attrByPath [ "systemConfig" "mymodules" "impermanence" ] { } args;

  cfg = config.mymodules.impermanence;
in
{
  imports = [ inputs.impermanence.nixosModules.home-manager.impermanence ];


  options.mymodules.impermanence = {
    enable = mkBoolOpt (attrByPath [ "enable" ] false systemImpermanence);
    location = mkOption {
      default = "${(attrByPath [ "location" ] "/persist" systemImpermanence)}";
      type = types.str;
    };
    hideMounts = mkBoolOpt (attrByPath [ "hideMounts" ] true systemImpermanence);
  };

  config = mkIf cfg.enable { };
}


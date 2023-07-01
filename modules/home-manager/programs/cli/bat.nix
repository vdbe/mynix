{ config, lib, mylib, ... }:

let
  inherit (lib) types;
  inherit (lib.modules) mkIf;
  inherit (lib.attrsets) optionalAttrs;
  inherit (lib.options) literalExpression mkOption;
  inherit (mylib) mkBoolOpt;

  cfg = config.mymodules.programs.cli.bat;

  shellAliases = { } // optionalAttrs cfg.enableAliases {
    cat = "bat -p";
  };
in
{

  options.mymodules.programs.cli.bat = {
    enable = mkBoolOpt false;

    enableAliases = mkOption {
      default = true;
      description = "recommended bat aliases (cat)";
      type = types.bool;
    };

    extraPackages = mkOption {
      type = types.listOf types.package;
      default = [ ];
      example = literalExpression
        "with pkgs.bat-extras; [ batdiff batman batgrep batwatch ];";
      description = ''
        Additional bat packages to install.
      '';
    };
  };

  config = mkIf cfg.enable {
    programs = {
      bat = {
        inherit (cfg) enable extraPackages;
      };
    };
    home.shellAliases = shellAliases;

    mymodules.impermanence.cache.directories = [
      ".cache/bat"
    ];
  };


}

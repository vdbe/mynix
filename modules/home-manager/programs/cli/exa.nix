{ config, lib, ... }:

let
  inherit (lib) types;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.modules) mkIf mkMerge;

  cfg = config.mymodules.programs.cli.exa;
in
{

  options.mymodules.programs.cli.exa = {
    enable =
      mkEnableOption "exa, a modern replacement for <command>ls</command>";

    enableAliases = mkOption {
      default = true;
      description = "recommended exa aliases (ls, ll…)";
      type = types.bool;
    };

    extraOptions = mkOption {
      type = types.listOf types.str;
      default = [ "--group-directories-first" ];
      example = [ "--group-directories-first" "--header" ];
      description = ''
        Extra command line options passed to exa.
      '';
    };

    icons = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Display icons next to file names (<option>--icons</option> argument).
      '';
    };

    git = mkOption {
      type = types.bool;
      default = config.mymodules.programs.cli.git.enable;
      description = ''
        List each file's Git status if tracked or ignored (<option>--git</option> argument).
      '';
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      programs.exa = {
        enable = true;

        inherit (cfg) enableAliases extraOptions icons git;
      };
    }

    (mkIf cfg.enableAliases {
      home.shellAliases = {
        lp = "ll --octal-permissions";
      };
    })

  ]);
}

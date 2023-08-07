{ config, lib, mylib, ... }:

let
  inherit (lib.modules) mkIf;
  inherit (mylib) mkBoolOpt;

  cfg = config.mymodules.programs.cli.nushell;
in
{
  options.mymodules.programs.cli.nushell = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    programs.nushell = {
      enable = true;
    };

    mymodules.impermanence.state.files =
      let
        historyFile = ".config/nushell/history.txt";
      in
      [
        historyFile
      ];
  };
}

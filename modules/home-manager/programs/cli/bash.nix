args@{ config, lib, mylib, ... }:

let
  inherit (lib.attrsets) attrByPath;
  inherit (lib.modules) mkIf;
  inherit (mylib) mkBoolOpt;

  cfg = config.mymodules.programs.cli.bash;
in
{
  options.mymodules.programs.cli.bash = {
    enable = mkBoolOpt (attrByPath [ "systemConfig" "mymodules" "programs" "cli" "bash" "enable" ] false args);
  };

  config = mkIf cfg.enable {
    programs.bash = {
      enable = true;
      historyControl = [ "erasedups" "ignoredups" "ignorespace" ];
    };

    mymodules.impermanence.state.files =
      let
        historyFile' = config.programs.bash.historyFile;
        historyFile = if historyFile' == null then ".bash_history" else historyFile';
      in
      [
        historyFile
      ];
  };
}

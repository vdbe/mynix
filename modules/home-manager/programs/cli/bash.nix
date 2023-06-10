args@{ config, options, lib, mylib, ... }:

let
  inherit (lib.attrsets) attrByPath;
  inherit (lib.modules) mkIf mkMerge;
  inherit (mylib) mkBoolOpt;

  inherit (config.mymodules) impermanence;

  cfg = config.mymodules.programs.cli.bash;
in
{
  options.mymodules.programs.cli.bash = {
    enable = mkBoolOpt (attrByPath [ "systemConfig" "mymodules" "programs" "cli" "bash" "enable" ] false args);
  };

  config = mkIf cfg.enable (mkMerge [
    {
      programs.bash = {
        enable = true;
        historyControl = [ "erasedups" "ignoredups" "ignorespace" ];
      };
    }

    (mkIf impermanence.enable {
      home.persistence."${impermanence.location}/cache/users/${config.home.username}" = {
        removePrefixDirectory = false;
        allowOther = true;
        files =
          let
            historyFile' = config.programs.bash.historyFile;
            historyFile = if historyFile' == null then ".bash_history" else historyFile';
          in
          [
            historyFile
          ];
      };
    })

  ]);
}


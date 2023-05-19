args@{ config, options, lib, mylib, ... }:

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
    };
  };
}


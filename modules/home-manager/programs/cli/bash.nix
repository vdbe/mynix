args@{ config, options, lib, mylib, ... }:

let
  inherit (lib.attrsets) attrByPath;
  inherit (lib.modules) mkIf;
  inherit (mylib) mkBoolOpt;

  cfg = config.modules.programs.cli.bash;
in
{
  options.modules.programs.cli.bash = {
    enable = mkBoolOpt (attrByPath [ "systemConfig" "modules" "programs" "cli" "bash" "enable" ] false args);
  };

  config = mkIf cfg.enable {
    programs.bash = {
      enable = true;
    };
  };
}


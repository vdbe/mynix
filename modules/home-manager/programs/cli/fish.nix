args@{ config, options, lib, mylib, ... }:

let
  inherit (lib.attrsets) attrByPath;
  inherit (lib.modules) mkIf;
  inherit (mylib) mkBoolOpt;

  cfg = config.modules.programs.cli.fish;
in
{
  options.modules.programs.cli.fish = {
    enable = mkBoolOpt (attrByPath [ "systemConfig" "modules" "programs" "cli" "fish" "enable" ] false args);
  };

  config = mkIf cfg.enable {
    programs.fish = {
      enable = true;
      interactiveShellInit = ''
        # Disable greeting message
        set --universal fish_greeting
      '';
    };
  };
}


args@{ config, lib, mylib, ... }:

let
  inherit (lib.attrsets) attrByPath;
  inherit (lib.modules) mkIf;
  inherit (mylib) mkBoolOpt;


  cfg = config.mymodules.programs.cli.fish;
in
{
  options.mymodules.programs.cli.fish = {
    enable = mkBoolOpt (attrByPath [ "systemConfig" "mymodules" "programs" "cli" "fish" "enable" ] false args);
  };

  config = mkIf cfg.enable {
    programs.fish = {
      enable = true;
      interactiveShellInit = ''
        # Disable greeting message
        set --universal fish_greeting
      '';
    };

    mymodules.impermanence.state.files = [
      ".local/share/fish/fish_history"
    ];

  };
}

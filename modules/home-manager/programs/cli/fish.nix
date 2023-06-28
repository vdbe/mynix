args@{ config, options, lib, mylib, ... }:

let
  inherit (lib.attrsets) attrByPath;
  inherit (lib.modules) mkIf mkMerge;
  inherit (mylib) mkBoolOpt;

  inherit (config.mymodules) impermanence;

  cfg = config.mymodules.programs.cli.fish;
in
{
  options.mymodules.programs.cli.fish = {
    enable = mkBoolOpt (attrByPath [ "systemConfig" "mymodules" "programs" "cli" "fish" "enable" ] false args);
  };

  config = mkIf cfg.enable (mkMerge [
    {
      programs.fish = {
        enable = true;
        interactiveShellInit = ''
          # Disable greeting message
          set --universal fish_greeting
        '';
      };

    }

    (mkIf impermanence.enable {
      home.persistence."${impermanence.location}/state/users/${config.home.username}" = {
        files = [
          ".local/share/fish/fish_history"
        ];
        allowOther = true;
        removePrefixDirectory = false;
      };
    })
  ]);
}


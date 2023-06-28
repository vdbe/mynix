{ config, options, lib, mylib, pkgs, ... }:

let
  inherit (lib.modules) mkIf mkMerge mkDefault;
  inherit (mylib) mkBoolOpt;

  fdOptions = "--strip-cwd-prefix --hidden --follow --exclude .git";

  cfg = config.mymodules.programs.cli.fzf;
in
{

  options.mymodules.programs.cli.fzf = {
    enable = mkBoolOpt false;

    tmux = {
      enableShellIntegration = mkBoolOpt config.mymodules.programs.cli.tmux.enable;
    };
  };

  config = mkIf cfg.enable {
    programs.fzf = mkMerge [
      {
        enable = true;

        tmux.enableShellIntegration = cfg.tmux.enableShellIntegration;
        changeDirWidgetOptions = [ "--preview '${pkgs.tree}/bin/tree -L 2 -C {}'" ];
      }

      (mkIf config.mymodules.programs.cli.fd.enable {
        defaultCommand = mkDefault "fd --type f ${fdOptions}";
        fileWidgetCommand = mkDefault "fd --type f ${fdOptions}";
        changeDirWidgetCommand = mkDefault "fd --type d ${fdOptions}";
      })

      (if config.mymodules.programs.cli.bat.enable then {
        fileWidgetOptions = [ "--preview 'bat --color always -p {}'" ];
      } else {
        fileWidgetOptions = [ "--preview 'cat {}'" ];
      })
    ];
  };
}

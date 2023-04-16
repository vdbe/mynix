{ config, lib, mylib, inputs, ... }:

let
  inherit (lib.modules) mkIf;
  inherit (mylib) mkBoolOpt;

  tmuxConfig = inputs.myconfig + /tmux;

  cfg = config.modules.programs.cli.tmux;
in
{
  options.modules.programs.cli.tmux = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    programs.tmux = {
      enable = true;
    };

    xdg.configFile."tmux/tmux.conf".source = tmuxConfig + "tmux.conf";
    xdg.configFile."tmux/theme.conf".source = tmuxConfig + "theme.conf";
  };
}

{ config, lib, mylib, ... }:

let
  inherit (lib.modules) mkIf mkDefault;
  inherit (mylib) mkBoolOpt;

  cfg = config.mymodules.programs.cli.neovim;
in
{
  options.mymodules.programs.cli.neovim = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    programs.neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
      withNodeJs = true;
      withRuby = true;
      withPython3 = true;
      defaultEditor = true;
    };

    mymodules = {

      programs.cli = {
        ripgrep.enable = mkDefault true;
        fd.enable = mkDefault true;
      };
      impermanence = {
        data.directories = [
          ".config/nvim"
        ];
        state.directories = [
          ".local/share/nvim" # NOTE: maybe cache
          ".local/state/nvim"
        ];
        cache.directories = [
          ".cache/nvim"
        ];
      };
    };
  };


}

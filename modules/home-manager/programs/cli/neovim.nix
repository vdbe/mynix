{ config, options, lib, mylib, ... }:

let
  inherit (lib.modules) mkIf mkMerge mkDefault;
  inherit (mylib) mkBoolOpt;

  inherit (config.mymodules) impermanence;

  cfg = config.mymodules.programs.cli.neovim;
in
{
  options.mymodules.programs.cli.neovim = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable (mkMerge [
    {
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

      mymodules.programs.cli = {
        ripgrep.enable = mkDefault true;
        fd.enable = mkDefault true;
      };
    }

    (mkIf impermanence.enable {
      home.persistence."${impermanence.location}/data/users/${config.home.username}" = {
        removePrefixDirectory = false;
        allowOther = true;
        directories = [
          ".config/nvim"
        ];
      };
      home.persistence."${impermanence.location}/state/users/${config.home.username}" = {
        removePrefixDirectory = false;
        allowOther = true;
        directories = [
          ".local/share/nvim"
          ".local/state/nvim"
        ];
      };
      home.persistence."${impermanence.location}/cache/users/${config.home.username}" = {
        removePrefixDirectory = false;
        allowOther = true;
        directories = [
          ".cache/nvim"
        ];
      };
    })

  ]);
}


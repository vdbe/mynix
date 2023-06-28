{ config, options, lib, mylib, ... }:

let
  inherit (lib.modules) mkIf mkMerge;
  inherit (mylib) mkBoolOpt;

  inherit (config.mymodules) impermanence;
  cfg = config.mymodules.xdg;
in
{
  options.mymodules.xdg = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable (mkMerge [
    {
      # TODO: impermanence
      xdg = {
        enable = true;
        mime.enable = true;
        mimeApps.enable = true;
        userDirs = {
          enable = true;
          createDirectories = true;
        };
      };
    }

    (mkIf impermanence.enable {
      home.persistence."${impermanence.location}/data/users/${config.home.username}" = {
        removePrefixDirectory = false;
        allowOther = true;
        directories = [
          "Desktop"
          "Documents"
          "Downloads"
          "Music"
          "Pictures"
          "Public"
          "Templates"
          "Videos"
        ];
      };
    })

  ]);
}


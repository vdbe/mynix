{ config, options, lib, mylib, ... }:

let
  inherit (lib.modules) mkIf;
  inherit (mylib) mkBoolOpt;

  cfg = config.mymodules.xdg;
in
{
  options.mymodules.xdg = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
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
  };
}


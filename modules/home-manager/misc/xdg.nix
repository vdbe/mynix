{ config, options, lib, mylib, ... }:

let
  inherit (lib.modules) mkIf;
  inherit (mylib) mkBoolOpt;

  cfg = config.modules.xdg;
in
{
  options.modules.xdg = {
    enable = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
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


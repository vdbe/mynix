{ config, options, ... }:

let

  cfg = config.mymodules.services.displayManager;
in
{
  # TODO: Assert to check if their is only one displayManager active
  options.mymodules.services.displayManager = {
    inherit (options.services.xserver.displayManager) defaultSession;
  };

  config = {
    services.xserver.displayManager = {
      inherit (cfg) defaultSession;
    };
  };
}


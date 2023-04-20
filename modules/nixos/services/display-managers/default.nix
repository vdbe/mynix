{ config, options, ... }:

let

  cfg = config.modules.services.displayManager;
in
{
  # TODO: Assert to check if their is only one displayManager active
  options.modules.services.displayManager = {
    inherit (options.services.xserver.displayManager) defaultSession;
  };

  config = {
    services.xserver.displayManager = {
      inherit (cfg) defaultSession;
    };
  };
}


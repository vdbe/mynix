{
  description = "My home-manager modules";

  inputs = {
    myconfig.url = "path:../../config";
    myconfig.flake = false;
  };

  outputs = _:
    {
      homeManagerModules = {
        default = import (builtins.path { path = ./.; name = "myhomemanagermodules"; });
      };
    };

}

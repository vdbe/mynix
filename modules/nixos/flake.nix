{
  description = "My nixos modules";

  outputs = _:
    {
      nixosModules = {
        default = import (builtins.path { path = ./.; name = "myhomemanagermodules"; });
      };
    };

}

{
  description = "My home-manager modules";

  inputs = {
    myconfig.url = "path:../../config";
    myconfig.flake = false;
  };

  outputs = inputs@{ ... }:
    {
      homeManagerModules = {
        default = import ./.;
      };
    };

}

{
  description = "My nixos modules";

  outputs = { ... }:
    {
      nixosModules = {
        default = import ./.;
      };
    };

}

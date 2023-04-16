{
  description = "My nixos modules";

  outputs = _:
    {
      nixosModules = {
        default = import ./.;
      };
    };

}

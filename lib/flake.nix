{
  description = "My lib";

  inputs = {
    nixpkgs-lib.url = "github:NixOS/nixpkgs/nixos-unstable?dir=lib";
  };

  outputs = { nixpkgs-lib, ... }:
    {
      lib = import ./. { inherit (nixpkgs-lib) lib; };
    };

}

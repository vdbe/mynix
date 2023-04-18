{
  description = "My custom packages";

  inputs = {
    systems.url = "github:vdbe/nix-systems";

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self
    , nixpkgs
    , systems
    , ...
    }:

    let
      forAllSystems = nixpkgs.lib.genAttrs (import systems);

      mkPkgs = system: pkgs: import pkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      packages = forAllSystems (system:
        import (builtins.path { path = ./.; name = "mypackages"; }) {
          pkgs = mkPkgs system nixpkgs;
        }
      );

      legacyPackages = self.packages;
    };
}



{
  description = "My custom packages";

  inputs = {
    systems.url = "github:vdbe/nix-systems";

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-utils.url = "github:numtide/flake-utils";
    flake-utils.inputs.systems.follows = "";
  };

  outputs =
    { self
    , flake-utils
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
        import ./. {
          inherit flake-utils;
          pkgs = mkPkgs system nixpkgs;
        }
      );

      legacyPackages = self.packages;
    };
}



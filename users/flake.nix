{
  description = "My homeConfigurations";

  inputs = {
    systems.url = "github:vdbe/nix-systems";

    nixpkgs.url = "nixpkgs/nixos-22.11";
    nixpkgs-unstable.url = "nixpkgs/nixpkgs-unstable";

    home-manager.url = "github:nix-community/home-manager/release-22.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    myconfig.url = "path:../config";
    myconfig.flake = false;

    mylib.url = "path:../lib";
    mylib.inputs.nixpkgs-lib.follows = "nixpkgs";

    mypackages.url = "path:../packages";
    mypackages.inputs.nixpkgs.follows = "nixpkgs";
    mypackages.inputs.systems.follows = "systems";

    myoverlays.url = "path:../overlays";
    myoverlays.flake = false;

    myhomemanagermodules.url = "path:../modules/home-manager";
    myhomemanagermodules.inputs.myconfig.follows = "myconfig";
  };

  outputs =
    inputs@{ self
    , nixpkgs
    , nixpkgs-unstable
    , systems
    , mypackages
    , myhomemanagermodules
    , ...
    }:
    let
      inherit (builtins) path;
      inherit (nixpkgs.lib.attrsets) genAttrs;
      inherit (inputs.mylib.lib) mkPkgs;

      inherit (nixpkgs) lib;
      mylib = inputs.mylib.lib;

      forAllSystems = genAttrs (import systems);

      homeConfigurations = import (path { path = ./.; name = "myhomemanager"; }) {
        inherit self pkgs lib mylib inputs;
        pkgs-unstable = pkgs';
      };

      activationPackages = genAttrs (builtins.attrNames self.homeConfigurations) (home: self.homeConfigurations.${home}.activationPackage);

      pkgs = forAllSystems (system: mkPkgs system nixpkgs [ self.overlays.my self.overlays.unstable ]);
      pkgs' = forAllSystems (system: mkPkgs system nixpkgs-unstable [ self.overlays.my self.overlays.unstable ]);
    in
    {
      inherit (myhomemanagermodules) homeManagerModules;
      inherit homeConfigurations;

      # TODO: integrate myoverlays
      overlays = {
        my = final: _prev: {
          my = mypackages.packages.${final.system};
        };
        unstable = final: _prev: {
          unstable = pkgs'.${final.system};
        };
      };

      packages = forAllSystems (_: activationPackages);

    };
}

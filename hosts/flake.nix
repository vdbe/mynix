{
  description = "My nixosConfigurations";

  inputs = {
    systems.url = "github:vdbe/nix-systems";

    nixpkgs.url = "nixpkgs/nixos-22.11";
    nixpkgs-unstable.url = "nixpkgs/nixpkgs-unstable";

    home-manager.url = "github:nix-community/home-manager/release-22.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.inputs.nixpkgs-stable.follows = "nixpkgs";

    myconfig.url = "path:../config";
    myconfig.flake = false;

    mysecrets.url = "path:../secrets";
    mysecrets.flake = false;

    mylib.url = "path:../lib";
    mylib.inputs.nixpkgs-lib.follows = "nixpkgs";

    mypackages.url = "path:../packages";
    mypackages.inputs.nixpkgs.follows = "nixpkgs";
    mypackages.inputs.systems.follows = "systems";

    mynixosmodules.url = "path:../modules/nixos";

    myhomemanager.url = "path:../users";
    myhomemanager.inputs.systems.follows = "systems";
    myhomemanager.inputs.nixpkgs.follows = "nixpkgs";
    myhomemanager.inputs.nixpkgs-unstable.follows = "nixpkgs-unstable";
    myhomemanager.inputs.home-manager.follows = "home-manager";
    myhomemanager.inputs.myconfig.follows = "myconfig";
    myhomemanager.inputs.mylib.follows = "mylib";
    myhomemanager.inputs.mypackages.follows = "mypackages";
  };

  outputs =
    inputs@{ self
    , nixpkgs
    , nixpkgs-unstable
    , systems
    , mypackages
    , mynixosmodules
    , ...
    }:
    let
      inherit (nixpkgs.lib.attrsets) genAttrs;
      inherit (inputs.mylib.lib) mkPkgs;
      inherit (nixpkgs.lib.modules) mkDefault;

      lib = nixpkgs.lib;
      mylib = inputs.mylib.lib;

      forAllSystems = genAttrs (import systems);

      pkgs = forAllSystems (system: mkPkgs system nixpkgs [ self.overlays.my self.overlays.unstable ]);
      pkgs' = forAllSystems (system: mkPkgs system nixpkgs-unstable [ self.overlays.my ]);
    in
    {
      inherit (mynixosmodules) nixosModules;
      inherit (inputs.myhomemanager) homeManagerModules;
      inherit inputs;

      # TODO: integrate myoverlays
      overlays = {
        my = final: prev: {
          my = mypackages.packages.${final.system};
        };
        unstable = final: prev: {
          unstable = pkgs'.${final.system};
        };
      };


      nixosConfigurations = import ./. {
        inherit self pkgs lib mylib inputs;
      };

    };
}

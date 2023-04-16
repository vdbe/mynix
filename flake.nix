{
  description = "Description for the project";

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

    myconfig.url = "path:./config";
    myconfig.flake = false;

    mysecrets.url = "path:./secrets";
    mysecrets.flake = false;

    mylib.url = "path:./lib";
    mylib.inputs.nixpkgs-lib.follows = "nixpkgs";

    mypackages.url = "path:./packages";
    mypackages.inputs.systems.follows = "systems";
    mypackages.inputs.nixpkgs.follows = "nixpkgs";

    mynixosmodules.url = "path:./modules/nixos";

    myhomemanagermodules.url = "path:./modules/home-manager";
    myhomemanagermodules.inputs.myconfig.follows = "myconfig";

    myhomemanager.url = "path:./users";
    myhomemanager.inputs.systems.follows = "systems";
    myhomemanager.inputs.nixpkgs.follows = "nixpkgs";
    myhomemanager.inputs.nixpkgs-unstable.follows = "nixpkgs-unstable";
    myhomemanager.inputs.home-manager.follows = "home-manager";
    myhomemanager.inputs.myconfig.follows = "myconfig";
    myhomemanager.inputs.mylib.follows = "mylib";
    myhomemanager.inputs.mypackages.follows = "mypackages";
    myhomemanager.inputs.myhomemanagermodules.follows = "myhomemanagermodules";

    mynixos.url = "path:./hosts";
    mynixos.inputs.systems.follows = "systems";
    mynixos.inputs.nixpkgs.follows = "nixpkgs";
    mynixos.inputs.nixpkgs-unstable.follows = "nixpkgs-unstable";
    mynixos.inputs.home-manager.follows = "home-manager";
    mynixos.inputs.sops-nix.follows = "sops-nix";
    mynixos.inputs.nixos-hardware.follows = "nixos-hardware";
    mynixos.inputs.myconfig.follows = "myconfig";
    mynixos.inputs.mysecrets.follows = "mysecrets";
    mynixos.inputs.mylib.follows = "mylib";
    mynixos.inputs.mypackages.follows = "mypackages";
    mynixos.inputs.mynixosmodules.follows = "mynixosmodules";
    mynixos.inputs.myhomemanager.follows = "myhomemanager";
  };

  outputs = inputs@{ self, nixpkgs, systems, ... }:
    let
      inherit (nixpkgs.lib.attrsets) genAttrs;
      inherit (inputs.mylib.lib) mkPkgs;

      mylib = inputs.mylib.lib;

      forAllSystems = genAttrs (import systems);

      pkgs = forAllSystems (system: mkPkgs system nixpkgs [ self.overlays.my ]);
      #pkgs' = forAllSystems (system: mkPkgs system nixpkgs-unstable [ self.overlays.my ]);

    in
    {
      inherit inputs;
      inherit (inputs.mypackages) packages;

      inherit (inputs.mynixosmodules) nixosModules;
      inherit (inputs.myhomemanagermodules) homeManagerModules;

      inherit (inputs.mynixos) nixosConfigurations;
      inherit (inputs.myhomemanager) homeConfigurations;

      inherit (inputs.mylib) lib;

      formatter = forAllSystems (system: pkgs.${system}.nixpkgs-fmt);

      overlays = import ./overlays { extraPackages = self.packages; } // {
        my = final: _prev: {
          my = self.packages.${final.system};
        };
      };
    };
}

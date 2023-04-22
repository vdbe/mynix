{
  description = "Description for the project";

  inputs = {
    systems.url = "github:vdbe/nix-systems";

    nixpkgs.url = "nixpkgs/nixos-22.11";
    nixpkgs-unstable.url = "nixpkgs/nixpkgs-unstable";

    home-manager.url = "github:nix-community/home-manager/release-22.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
    pre-commit-hooks.inputs.nixpkgs.follows = "nixpkgs-unstable";
    pre-commit-hooks.inputs.nixpkgs-stable.follows = "nixpkgs";

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

    myoverlays.url = "path:./overlays";
    myoverlays.flake = false;

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
    myhomemanager.inputs.myoverlays.follows = "myoverlays";
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
    mynixos.inputs.myoverlays.follows = "myoverlays";
    mynixos.inputs.mynixosmodules.follows = "mynixosmodules";
    mynixos.inputs.myhomemanager.follows = "myhomemanager";
  };

  outputs = inputs@{ self, nixpkgs, systems, ... }:
    let
      inherit (builtins) path;
      inherit (nixpkgs.lib.attrsets) genAttrs recursiveUpdate;
      inherit (inputs.mylib.lib) mkPkgs;

      mylib = inputs.mylib.lib;
      mynix = path {
        path = ./.;
        name = "mynix";
      };

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

      checks = forAllSystems (system: {
        pre-commit-check = inputs.pre-commit-hooks.lib.${system}.run {
          src = mynix;
          hooks = {
            deadnix.enable = true;
            nixpkgs-fmt.enable = true;
            statix.enable = true;
          };
        };
      });

      legacyPackages = recursiveUpdate self.packages inputs.myhomemanager.packages;

      formatter = forAllSystems (system: pkgs.${system}.nixpkgs-fmt);

      # TODO:
      overlays = /* import ./overlays { extraPackages = self.packages; } // */ {
        my = final: _prev: {
          my = self.packages.${final.system};
        };
      };

      devShells = forAllSystems (system:
        let pkgs' = pkgs.${system}; in
        {
          default = pkgs'.mkShell {
            buildInputs = with pkgs'; [
              nixos-rebuild
              statix
              deadnix
            ];
            shellHook = ''
              ${self.checks.${system}.pre-commit-check.shellHook}
            '';
          };
        });

    };
}

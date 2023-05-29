{
  description = "Description for the project";

  inputs = {
    systems.url = "github:vdbe/nix-systems";

    nixpkgs.url = "nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "nixpkgs/nixpkgs-unstable";

    flake-utils.url = "github:numtide/flake-utils";
    flake-utils.inputs.systems.follows = "systems";

    flake-compat.url = "github:edolstra/flake-compat";
    flake-compat.flake = false;

    home-manager.url = "github:nix-community/home-manager/release-23.05";
    #home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
    pre-commit-hooks.inputs.nixpkgs.follows = "nixpkgs-unstable";
    pre-commit-hooks.inputs.nixpkgs-stable.follows = "nixpkgs";
    pre-commit-hooks.inputs.flake-utils.follows = "flake-utils";
    pre-commit-hooks.inputs.flake-compat.follows = "flake-compat";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.inputs.nixpkgs-stable.follows = "nixpkgs";

    deploy-rs.url = "github:serokell/deploy-rs";
    deploy-rs.inputs.nixpkgs.follows = "nixpkgs";
    deploy-rs.inputs.utils.follows = "flake-utils";
    deploy-rs.inputs.flake-compat.follows = "flake-compat";

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

      mynix = path {
        path = ./.;
        name = "mynix";
      };

      forAllSystems = genAttrs (import systems);

      pkgs = forAllSystems (system: mkPkgs system nixpkgs [ self.overlays.my ]);
      #pkgs' = forAllSystems (system: mkPkgs system nixpkgs-unstable [ self.overlays.my ]);

      deploy = forAllSystems
        (system:
          let
            deployPkgs = mkPkgs system nixpkgs [
              inputs.deploy-rs.overlay
              (_self: super: {
                deploy-rs = {
                  inherit (pkgs.${system}) deploy-rs;
                  inherit (super.deploy-rs) lib;
                };
              })
            ];
          in
          {
            inherit (deployPkgs.deploy-rs) lib;
            bin = deployPkgs.deploy-rs.deploy-rs;
          }
        );
    in
    {
      inherit inputs;
      inherit (inputs.mypackages) packages;

      inherit (inputs.mynixosmodules) nixosModules;
      inherit (inputs.myhomemanagermodules) homeManagerModules;

      inherit (inputs.mynixos) nixosConfigurations;
      inherit (inputs.myhomemanager) homeConfigurations;

      inherit (inputs.mylib) lib;

      apps = forAllSystems (system: {
        default = self.apps.${system}.deploy;
        deploy = {
          type = "app";
          program = "${deploy.${system}.bin}/bin/deploy";
        };
      });

      checks = forAllSystems (system: recursiveUpdate
        {
          pre-commit = inputs.pre-commit-hooks.lib.${system}.run {
            src = mynix;
            hooks = {
              deadnix.enable = true;
              nixpkgs-fmt.enable = true;
              statix.enable = true;
            };
          };
        }
        (deploy.${system}.lib.deployChecks self.deploy)
      );

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
              # Checks
              deadnix
              nixpkgs-fmt
              statix

              # Deployment
              deploy.${system}.bin
              home-manager
              nixos-rebuild

              # Dev
              sops
            ];
            shellHook = ''
              ${self.checks.${system}.pre-commit.shellHook}
            '';
          };
        }
      );


      deploy.nodes = {
        buckbeak = {
          hostname = "buckbeak";
          sshUser = "user";
          profiles.user =
            let
              home = self.homeConfigurations."user@buckbeak";
              inherit (home.pkgs) system;
              user = home.config.home.username;
            in
            {
              inherit user;
              path = deploy.${system}.lib.activate.home-manager home;
            };
        };
        aragog = {
          hostname = "aragog";
          sshUser = "user";
          profiles.system =
            let
              nixosSystem = self.nixosConfigurations.aragog;
              inherit (nixosSystem.pkgs) system;
            in
            {
              user = "root";
              path = deploy.${system}.lib.activate.nixos nixosSystem;
            };
        };
        nixos01 = {
          hostname = "nixos01.lab.home.arpa";
          sshUser = "user";
          profiles.system =
            let
              nixosSystem = self.nixosConfigurations.nixos01;
              inherit (nixosSystem.pkgs) system;
            in
            {
              user = "root";
              path = deploy.${system}.lib.activate.nixos nixosSystem;
            };
        };
        nixos02 = {
          hostname = "nixos02.lab.home.arpa";
          sshUser = "user";
          profiles.system =
            let
              nixosSystem = self.nixosConfigurations.nixos02;
              inherit (nixosSystem.pkgs) system;
            in
            {
              user = "root";
              path = deploy.${system}.lib.activate.nixos nixosSystem;
            };
        };
      };
    };
}

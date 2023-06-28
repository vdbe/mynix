{
  description = "My nixos modules";

  inputs = {
    nixpkgs-unstable.url = "nixpkgs/nixpkgs-unstable";

    mypackages.url = "path:../packages";
  };

  outputs = { self, nixpkgs-unstable, mypackages, ... }:
    let
      mkPkgs = system: pkgs: overlays: import pkgs {
        inherit system overlays;
        config.allowUnfree = true;
      };
    in
    {
      overlays = {
        my = final: _prev: {
          my = mypackages.packages.${final.system};
        };
        unstable = final: _prev: {
          unstable = mkPkgs final.system nixpkgs-unstable [ self.overlays.my ];
        };
      };


    };
}

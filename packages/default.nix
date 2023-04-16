{ pkgs, flake-utils, ... }:
let
  inherit (flake-utils.lib) filterPackages flattenTree;

  packages = rec {
    test123 = pkgs.callPackage ./test123 { };
    testabc = pkgs.callPackage ./testabc { inherit test123; };

    maelstrom = pkgs.callPackage ./maelstrom { };
    fennel = pkgs.callPackage ./fennel { };
  };
in
filterPackages pkgs.system (flattenTree packages)

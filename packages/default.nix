{ pkgs ? import <nixpkgs> { }, lib ? pkgs.lib, ... }:
let
  inherit (lib.attrsets) filterAttrs;

  allSystems = [
    "aarch64-darwin"
    "aarch64-linux"
    "x86_64-darwin"
    "x86_64-linux"
  ];

  packages = rec {
    test123 = pkgs.callPackage ./test123 { };
    testabc = pkgs.callPackage ./testabc { inherit test123; };

    fennel = pkgs.callPackage ./fennel { };
    maelstrom = pkgs.callPackage ./maelstrom { };
  };

  # FROM: https://github.com/numtide/flake-utils/
  op = sum: path: val:
    let
      pathStr = builtins.concatStringsSep "/" path;
    in
    if (builtins.typeOf val) != "set" then
    # ignore that value
    # builtins.trace "${pathStr} is not of type set"
      sum
    else if val ? type && val.type == "derivation" then
    # builtins.trace "${pathStr} is a derivation"
    # we used to use the derivation outPath as the key, but that crashes Nix
    # so fallback on constructing a static key
      (sum // {
        "${pathStr}" = val;
      })
    else if val ? recurseForDerivations && val.recurseForDerivations then
    # builtins.trace "${pathStr} is a recursive"
    # recurse into that attribute set
      (recurse sum path val)
    else
    # ignore that value
    # builtins.trace "${pathStr} is something else"
      sum;

  recurse = sum: path: val:
    builtins.foldl'
      (sum: key: op sum (path ++ [ key ]) val.${key})
      sum
      (builtins.attrNames val);

  flattenTree = recurse { } [ ];

  # Everything that nix flake check requires for the packages output
  sieve = _n: v:
    with v;
    let
      inherit (builtins) isAttrs;
      isDerivation = x: isAttrs x && x ? type && x.type == "derivation";
      isBroken = meta.broken or false;
      platforms = meta.platforms or allSystems;
      badPlatforms = meta.badPlatforms or [ ];
    in
    # check for isDerivation, so this is independently useful of
      # flattenTree, which also does filter on derivations
    isDerivation v && !isBroken && (builtins.elem system platforms) &&
    !(builtins.elem system badPlatforms);

  filterPackages = filterAttrs sieve;

in
filterPackages (flattenTree packages)

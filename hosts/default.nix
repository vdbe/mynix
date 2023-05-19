{ self, pkgs, lib, mylib, inputs, ... }:
let
  inherit (lib.attrsets) recursiveUpdate;
  inherit (mylib) mkHost;

  defaultConfiguration = ./configuration.nix;

  defaultSpecialArgs = { inherit self lib mylib inputs; };

  mkHost' = configurationPath: pkgs': extraSpecialArgs:
    let
      specialArgs = recursiveUpdate defaultSpecialArgs extraSpecialArgs;
    in
    mkHost defaultConfiguration configurationPath pkgs' specialArgs;
in
{
  local = mkHost' ./localVM pkgs { hostName = "local"; };
  nixos01 = mkHost' ./nixosVM pkgs { hostName = "nixos01"; };
  nixos02 = mkHost' ./nixosVM pkgs { hostName = "nixos02"; };

  aragog = mkHost' ./aragog pkgs { };
}

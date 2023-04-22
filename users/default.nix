{ self, pkgs, lib, mylib, inputs, systemConfig ? { }, ... }:
let
  inherit (lib.attrsets) recursiveUpdate;
  inherit (mylib) mkUser;

  defaultConfiguration = ./home.nix;

  defaultExtraSpecialArgs = { inherit self lib mylib inputs systemConfig; };

  mkUser' = configurationPath: extraSpecialArgs:
    let
      extraSpecialArgs' = recursiveUpdate defaultExtraSpecialArgs extraSpecialArgs;
    in
    mkUser defaultConfiguration configurationPath pkgs extraSpecialArgs';
in
{
  user = mkUser' ./user { };
  "user@aragog" = mkUser' (./user + "@aragog") { };
  "user@buckbeak" = mkUser' (./user + "@buckbeak") { };
}

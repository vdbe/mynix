{ self, pkgs, lib, mylib, inputs, systemConfig ? { }, ... }:
let
  inherit (builtins) path;
  inherit (lib.attrsets) recursiveUpdate;
  inherit (mylib) mkUser;

  cwd = path {
    path = ./.;
    name = "myhomemanager";
  };

  defaultConfiguration = ./home.nix;

  defaultExtraSpecialArgs = { inherit self lib mylib inputs systemConfig; };

  mkUser' = configurationPath: extraSpecialArgs:
    let
      extraSpecialArgs' = recursiveUpdate defaultExtraSpecialArgs extraSpecialArgs;
    in
    mkUser defaultConfiguration configurationPath pkgs extraSpecialArgs';
in
{
  user = mkUser' cwd + "/user" { };
  "user@aragog" = mkUser' (cwd + "/user@aragog") { };
  "user@buckbeak" = mkUser' (cwd + "/user@buckbeak") { };
}

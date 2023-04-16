{ self, pkgs, lib, mylib, inputs, systemConfig ? { }, ... }:
let
  inherit (lib.modules) mkDefault;
  inherit (mylib) mkUser;

  defaultConfiguration = ./home.nix;

  defaultExtraSpecialArgs = { inherit self lib mylib inputs systemConfig; };

  mkUser' = configurationPath: extraSpecialArgs:
    let
      extraSpecialArgs' = defaultExtraSpecialArgs // extraSpecialArgs;
    in
    (mkUser defaultConfiguration configurationPath pkgs extraSpecialArgs');
in
{
  user = mkUser' ./user { };
}

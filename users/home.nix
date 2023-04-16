{ self, config, pkgs, lib, ... }:

let
  inherit (lib.modules) mkDefault;
in
{
  imports = [
    self.homeManagerModules.default
  ];
  home = {
    homeDirectory = mkDefault "/${
        if pkgs.stdenv.isDarwin then "Users" else "home"
      }/${config.home.username}";

    stateVersion = "22.11";
  };
}

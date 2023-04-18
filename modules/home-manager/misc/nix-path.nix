{ config, pkgs, lib, mylib, inputs, ... }:
let
  inherit (lib) lists;
  inherit (lib.modules) mkIf;
  inherit (lib.strings) concatStringsSep;
  inherit (mylib) mkBoolOpt;

  cfg = config.modules.nix-path;

  nixPath = [ "nixpkgs=${pkgs.path}" ]
    ++ lists.optionals cfg.overlays.enable [
    "nixpkgs-unstable=${inputs.nixpkgs-unstable}"
    "mypkgs=${inputs.mypackages}"
    "nixpkgs-overlays=${inputs.myoverlays + /nixpkgs.nix}"
  ];

in
{
  options.modules.nix-path = {
    enable = mkBoolOpt false;

    overlays.enable = mkBoolOpt false;

    # TODO: option to append to nixPath
  };

  config = mkIf cfg.enable {
    home = {
      sessionVariables = {
        NIX_PATH = concatStringsSep ":" nixPath;
      };
    };
  };
}

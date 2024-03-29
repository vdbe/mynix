{ config, pkgs, lib, mylib, inputs, ... }:
let
  inherit (lib) lists;
  inherit (lib.modules) mkIf;
  inherit (lib.strings) concatStringsSep;
  inherit (mylib) mkBoolOpt;

  cfg = config.mymodules.nix-path;

  nixPath = [ "nixpkgs=${pkgs.path}" ]
    ++ lists.optionals cfg.overlays.enable [
    "nixpkgs-unstable=${inputs.nixpkgs-unstable}"
    "mypkgs=${inputs.mypackages}"
    "nixpkgs-overlays=${inputs.myoverlays + /nixpkgs.nix}"
  ];

in
{
  options.mymodules.nix-path = {
    enable = mkBoolOpt false;

    overlays.enable = mkBoolOpt false;

    # TODO: option to append to nixPath
  };

  config.home.sessionVariables = mkIf cfg.enable {
    NIX_PATH = concatStringsSep ":" nixPath;
  };

  # config = mkIf cfg.enable {
  #   #nixpkgs.config = {
  #   #  # TODO: Figure this out
  #   #  allowUnfreePredicate = _: true;
  #   #  allowUnfree = true;
  #   #  overlays = pkgs.overlays;
  #   #};
  #
  #   home = {
  #     sessionVariables = {
  #       NIX_PATH = concatStringsSep ":" nixPath;
  #     };
  #   };
  # };
}

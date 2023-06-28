{ config, pkgs, lib, mylib, inputs, ... }:
let
  inherit (lib) lists;
  inherit (lib.modules) mkIf;
  inherit (lib.strings) optionalString;
  inherit (mylib) mkBoolOpt;

  cfg = config.mymodules.nix-path;

  nixPath = [ "nixpkgs=/run/current-system/nixpkgs" ]
    ++ lists.optionals cfg.overlays.enable [
    "nixpkgs-unstable=/run/current-system/nixpkgs-unstable"
    "mypkgs=/run/current-system/mypkgs"
    "nixpkgs-overlays=/run/current-system/myoverlays/nixpkgs.nix"
  ];

in
{
  options.mymodules.nix-path = {
    enable = mkBoolOpt false;

    overlays.enable = mkBoolOpt false;

    # TODO: option to append to nix.nixPath
  };

  config = mkIf cfg.enable {
    nix.nixPath = nixPath;
    # TODO: look at nix.registry.<name>.flake
    # TODO: look at nixpkgs.overlays
    system.extraSystemBuilderCmds = ''
      ln -sv ${pkgs.path} $out/nixpkgs

      ${optionalString cfg.overlays.enable ''
      ln -sv ${inputs.nixpkgs-unstable} $out/nixpkgs-unstable
      #ln -sv ${inputs.mypackages} $out/mypkgs
      #ln -sv ${inputs.myoverlays} $out/myoverlays
      ''}
    '';
  };
}

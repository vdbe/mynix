{ config, pkgs, lib, mylib, inputs, ... }:
let
  inherit (lib) lists;
  inherit (lib.modules) mkIf;
  inherit (lib.strings) optionalString;
  inherit (mylib) mkBoolOpt;

  cfg = config.modules.nix-path;

  nixPath = [ "nixpkgs=/run/current-system/nixpkgs" ]
    ++ lists.optionals cfg.overlays.enable [
    "nixpkgs-unstable=/run/current-system/nixpkgs-unstable"
    "mypkgs=/run/current-system/mypkgs"
    "nixpkgs-overlays=/run/current-system/myoverlays/nixpkgs.nix"
  ];

in
{
  options.modules.nix-path = {
    enable = mkBoolOpt false;

    overlays.enable = mkBoolOpt false;

    # TODO: option to append to nix.nixPath
  };

  config = mkIf cfg.enable {
    nix.nixPath = nixPath;
    system.extraSystemBuilderCmds = ''
      ln -sv ${pkgs.path} $out/nixpkgs

      ${optionalString cfg.overlays.enable ''
      ln -sv ${inputs.nixpkgs-unstable} $out/nixpkgs-unstable
      ln -sv ${inputs.mypackages} $out/mypkgs
      ln -sv ${inputs.myoverlays} $out/myoverlays
      ''}
    '';
    # TODO: checkout nixpkgs.overlays
  };
}

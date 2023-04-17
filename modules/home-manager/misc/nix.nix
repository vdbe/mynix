{ config, pkgs, lib, mylib, inputs, ... }:
let
  inherit (lib) types;
  inherit (lib.attrsets) optionalAttrs;
  inherit (lib.modules) mkIf mkDefault;
  inherit (lib.options) mkOption;
  inherit (mylib) mkBoolOpt;

  cfg = config.modules.nix;
in
{
  options.modules.nix = {
    enable = mkBoolOpt false;

    trusted-substituters = mkOption {
      type = types.listOf types.str;
      default = [
        "https://cache.nixos.org?priority=10"
        "https://nix-community.cachix.org"

        "https://cache.garnix.io"
      ];
      example = [ "https://hydra.nixos.org/" ];
      description = lib.mdDoc ''
        List of binary cache URLs that non-root users can use (in
        addition to those specified using
        {option}`nix.settings.substituters`) by passing
        `--option binary-caches` to Nix commands.
      '';
    };

    trusted-public-keys = mkOption {
      type = types.listOf types.str;
      default = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="

        "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
      ];
      example = [ "hydra.nixos.org-1:CNHJZBh9K4tP3EKF6FkkgeVYsS3ohTl+oS0Qa8bezVs=" ];
      description = lib.mdDoc ''
        List of public keys used to sign binary caches. If
        {option}`nix.settings.trusted-public-keys` is enabled,
        then Nix will use a binary from a binary cache if and only
        if it is signed by *any* of the keys
        listed here. By default, only the key for
        `cache.nixos.org` is included.
      '';
    };
  };

  config = mkIf cfg.enable {
    nix = {
      extraOptions = ''
        experimental-features = nix-command flakes
        min-free = ${toString (100 * 1024 * 1024)}
        max-free = ${toString (1024 * 1024 * 1024)}
      '';

      nixPath = mkDefault [ ];


      gc = {
        automatic = true;
        persistent = true;
        dates = "weekly";
        options = "--delete-older-than 30d";
      };

      settings = {
        trusted-users = [ "root" "@wheel" ];
        auto-optimise-store = true;

        inherit (cfg) trusted-public-keys trusted-substituters;
      };
    };

    #system.stateVersion = vars.stateVersion;
  };
}

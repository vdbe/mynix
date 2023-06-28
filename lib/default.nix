{ lib, ... }:
let
  inherit (builtins) baseNameOf dirOf elemAt getAttr hasAttr length pathExists split;
  inherit (lib) nixosSystem types;
  inherit (lib.modules) mkDefault;
  inherit (lib.options) mkOption;
  inherit (lib.sources) pathIsDirectory;
  inherit (lib.strings) removeSuffix;
in
rec {
  getAttrWithDefault = default: attr: set:
    if hasAttr attr set then getAttr attr set else default;

  mkBoolOpt = default: mkOption {
    inherit default;
    type = types.bool;
    example = true;
  };

  mkPkgs = system: pkgs: overlays: import pkgs {
    inherit system overlays;
    config.allowUnfree = true;
  };

  mkHost = defaultConfigurationPath: configurationPath: pkgs: specialArgs:
    let
      isDir = pathIsDirectory configurationPath;
      configurationDir = if isDir then configurationPath else (dirOf configurationPath);
      configuration = if isDir then configurationDir + "/configuration.nix" else configurationPath;

      hostName = getAttrWithDefault
        # default
        (removeSuffix ".nix" (baseNameOf (if isDir then configurationDir else configurationPath)))
        # attr
        "hostName"
        # set
        specialArgs;

      system = getAttrWithDefault
        # default
        (
          if (isDir && pathExists (configurationDir + "/system.nix"))
          then
            (import (configurationDir + "/system.nix"))
          else
            "x86_64-linux"
        )
        # attribute
        "system"
        # set
        specialArgs;
    in
    nixosSystem {
      inherit system;
      specialArgs = { inherit system; } // specialArgs;
      modules = [
        {
          nixpkgs = {
            pkgs = mkDefault pkgs.${system};
            hostPlatform = mkDefault system;
          };
          networking.hostName = mkDefault hostName;
        }
        defaultConfigurationPath
        configuration
      ];
    };

  mkHomeLib = lib: inputs: lib.extend (_self: _super: inputs.home-manager.lib);

  mkExtraSpecialArgs = systemConfig: args@{ self, pkgs, lib, mylib, inputs, system, ... }: (builtins.removeAttrs args [ "config" "options" "lib" ]) // {
    inherit systemConfig self pkgs mylib system inputs;
    lib = mkHomeLib lib inputs;
  };

  mkUser = defaultConfigurationPath: configurationPath: pkgs: extraSpecialArgs' @ { inputs, ... }:
    let
      inherit (inputs.home-manager.lib) homeManagerConfiguration;

      isDir = pathIsDirectory configurationPath;
      configurationDir = if isDir then configurationPath else (dirOf configurationPath);
      configuration = if isDir then configurationDir + "/home.nix" else configurationPath;

      username =
        let
          # get everything _before_ last '@' (readability at its finest)
          at_split = split "^(.+?.)@.*"
            (baseNameOf (if isDir then configurationDir else configurationPath));

          # if no @ at_split length is 1 and elemAt 1 would fail
          name =
            if (length at_split) == 1
            then
              elemAt at_split 0
            else
              elemAt (elemAt at_split 1) 0;
        in
        getAttrWithDefault
          # default
          name
          # attr
          "username"
          # set
          extraSpecialArgs';


      system = getAttrWithDefault
        # default
        (
          if (isDir && pathExists (configurationDir + "/system.nix"))
          then
            (import (configurationDir + "/system.nix"))
          else
            "x86_64-linux"
        )
        # attribute
        "system"
        # set
        extraSpecialArgs';


      homeLib = mkHomeLib extraSpecialArgs'.lib inputs;
    in
    homeManagerConfiguration {
      extraSpecialArgs = {
        inherit system;
        inherit (extraSpecialArgs') self mylib inputs;
        lib = homeLib;
      };
      pkgs = pkgs.${system};
      modules = [
        {
          home.username = mkDefault username;
        }
        defaultConfigurationPath
        configuration
      ];
    };
}

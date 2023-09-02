args@{ config, lib, mylib, inputs, ... }:

let
  inherit (lib) types;
  inherit (lib.attrsets) attrByPath;
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkOption;
  inherit (mylib) mkBoolOpt;

  systemImpermanence = attrByPath [ "systemConfig" "mymodules" "impermanence" ] { } args;

  inherit (config.home) username homeDirectory;

  cfg = config.mymodules.impermanence;
in
{
  imports = [ inputs.impermanence.nixosModules.home-manager.impermanence ];


  options.mymodules.impermanence =
    let
      # FROM: https://github.com/nix-community/impermanence/blob/89253fb1518063556edd5e54509c30ac3089d5e6/home-manager.nix#L50-L104
      directories = mkOption {
        type = with types; listOf (either str (submodule {
          options = {
            directory = mkOption {
              type = str;
              default = null;
              description = "The directory path to be linked.";
            };
            method = mkOption {
              type = types.enum [ "bindfs" "symlink" ];
              default = "bindfs";
              description = ''
                The linking method that should be used for this
                directory. bindfs is the default and works for most use
                cases, however some programs may behave better with
                symlinks.
              '';
            };
          };
        }));
        default = [ ];
        example = [
          "Downloads"
          "Music"
          "Pictures"
          "Documents"
          "Videos"
          "VirtualBox VMs"
          ".gnupg"
          ".ssh"
          ".local/share/keyrings"
          ".local/share/direnv"
          {
            directory = ".local/share/Steam";
            method = "symlink";
          }
        ];
        description = ''
          A list of directories in your home directory that
          you want to link to persistent storage. You may optionally
          specify the linking method each directory should use.
        '';
      };

      files = mkOption {
        type = with types; listOf str;
        default = [ ];
        example = [
          ".screenrc"
        ];
        description = ''
          A list of files in your home directory you want to
          link to persistent storage.
        '';
      };


    in
    {
      enable = mkBoolOpt (attrByPath [ "enable" ] false systemImpermanence);
      location = mkOption {
        default = "${(attrByPath [ "location" ] "/persist" systemImpermanence)}";
        type = types.str;
      };
      #hideMounts = mkBoolOpt (attrByPath [ "hideMounts" ] true systemImpermanence);

      allowOther = mkBoolOpt (username != "root");
      removePrefixDirectory = mkBoolOpt false;

      # TODO: Refector to use types.submodle with enum cache/state/data as arg (maybe also location)
      data = {
        allowOther = mkBoolOpt cfg.allowOther;
        removePrefixDirectory = mkBoolOpt cfg.removePrefixDirectory;
        location = mkOption {
          default = "${cfg.location}/data/users/${username}${homeDirectory}";
          type = types.str;
        };
        inherit files directories;
      };
      state = {
        allowOther = mkBoolOpt cfg.allowOther;
        removePrefixDirectory = mkBoolOpt cfg.removePrefixDirectory;
        location = mkOption {
          default = "${cfg.location}/state/users/${username}${homeDirectory}";
          type = types.str;
        };
        inherit files directories;
      };
      cache = {
        allowOther = mkBoolOpt cfg.allowOther;
        removePrefixDirectory = mkBoolOpt cfg.removePrefixDirectory;
        location = mkOption {
          default = "${cfg.location}/cache/users/${username}${homeDirectory}";
          type = types.str;
        };
        inherit files directories;
      };
    };

  config = mkIf cfg.enable {
    home.persistence = {
      "${cfg.data.location}" = {
        inherit (cfg.data) allowOther removePrefixDirectory directories files;
      };
      "${cfg.state.location}" = {
        inherit (cfg.state) allowOther removePrefixDirectory directories files;
      };
      "${cfg.cache.location}" = {
        inherit (cfg.cache) allowOther removePrefixDirectory directories files;
      };
    };

  };
}

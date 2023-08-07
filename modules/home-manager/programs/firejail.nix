args@{ config, lib, mylib, pkgs, ... }:

# FROM: https://github.com/NixOS/nixpkgs/blob/9fdfaeb7b96f05e869f838c73cde8d98c640c649/nixos/modules/programs/firejail.nix
let
  inherit (lib.attrsets) attrByPath;
  inherit (lib.lists) optional;
  inherit (lib.options) mkOption literalExpression;
  inherit (lib) types;
  inherit (lib.modules) mkIf;
  inherit (mylib) mkBoolOpt;

  cfg = config.mymodules.programs.firejail;


  wrappedBins = pkgs.runCommand "hm-firejail-wrapped-binaries"
    {
      preferLocalBuild = true;
      allowSubstitutes = false;
      # take precedence over non-firejailed versions
      # and over system firejailed versions
      meta.priority = -2;
    }
    ''
      mkdir -p $out/bin
      mkdir -p $out/share/applications
      ${lib.concatStringsSep "\n" (lib.mapAttrsToList (command: value:
      let
        opts = if builtins.isAttrs value
        then value
        else { executable = value; desktop = null; profile = null; extraArgs = []; };
        args' = lib.escapeShellArgs (
          opts.extraArgs
          ++ (optional (opts.profile != null) "--profile=${toString opts.profile}")
        );
      in
      ''
        cat <<_EOF >$out/bin/${command}
        #! ${pkgs.runtimeShell} -e
        exec /run/wrappers/bin/firejail ${args'} -- ${toString opts.executable} "\$@"
        _EOF
        chmod 0755 $out/bin/${command}

        ${lib.optionalString (opts.desktop != null) ''
          substitute ${opts.desktop} $out/share/applications/$(basename ${opts.desktop}) \
            --replace ${opts.executable} $out/bin/${command}
        ''}
      '') cfg.wrappedBinaries)}
    '';
in
{
  options.mymodules.programs.firejail = {
    enable = mkBoolOpt (attrByPath [ "systemConfig" "mymodules" "programs" "firejail" "enable" ] false args);

    wrappedBinaries = mkOption {
      type = types.attrsOf (types.either types.path (types.submodule {
        options = {
          executable = mkOption {
            type = types.path;
            description = lib.mdDoc "Executable to run sandboxed";
            example = literalExpression ''"''${lib.getBin pkgs.firefox}/bin/firefox"'';
          };
          desktop = mkOption {
            type = types.nullOr types.path;
            default = null;
            description = lib.mkDoc ".desktop file to modify. Only necessary if it uses the absolute path to the executable.";
            example = literalExpression ''"''${pkgs.firefox}/share/applications/firefox.desktop"'';
          };
          profile = mkOption {
            type = types.nullOr types.path;
            default = null;
            description = lib.mdDoc "Profile to use";
            example = literalExpression ''"''${pkgs.firejail}/etc/firejail/firefox.profile"'';
          };
          extraArgs = mkOption {
            type = types.listOf types.str;
            default = [ ];
            description = lib.mdDoc "Extra arguments to pass to firejail";
            example = [ "--private=~/.firejail_home" ];
          };
        };
      }));
      default = { };
      example = literalExpression ''
        {
          firefox = {
            executable = "''${lib.getBin pkgs.firefox}/bin/firefox";
            profile = "''${pkgs.firejail}/etc/firejail/firefox.profile";
          };
          mpv = {
            executable = "''${lib.getBin pkgs.mpv}/bin/mpv";
            profile = "''${pkgs.firejail}/etc/firejail/mpv.profile";
          };
        }
      '';
      description = lib.mdDoc ''
        Wrap the binaries in firejail and place them in the global path.
      '';
    };

  };

  config = mkIf cfg.enable {
    home.packages = [ wrappedBins ];
  };
}

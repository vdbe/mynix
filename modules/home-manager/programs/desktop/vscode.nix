{ config, lib, mylib, pkgs, ... }:

let
  inherit (lib) types;
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkOption;
  inherit (mylib) mkBoolOpt;

  #jsonFormat = pkgs.formats.json { };

  # my-vscode-user-data-dir = pkgs.stdenv.mkDerivation {
  #   name = "my-vscode-data-dir";
  #   src = jsonFormat.generate "my-vscode-settings.json" cfg.userSettings;
  #   phases = [ "installPhase" ];
  #   installPhase = ''
  #     mkdir -p $out
  #     cp $src $out/settings.json
  #   '';
  # };

  #my-vscode = (pkgs.vscode-with-extensions.overrideAttrs (old: {
  #  # Add the --user-data-dir flag
  #  buildCommand = old.buildCommand + ''sed -i 's#\("$@"\)#--user-data-dir ${my-vscode-user-data-dir} \1#' $out/bin/code'';
  #})).override
  #  {
  #    vscode = cfg.package;
  #    vscodeExtensions = cfg.extensions;
  #  };
  my-vscode = pkgs.vscode-with-extensions.override {
    vscode = cfg.package;
    vscodeExtensions = cfg.extensions;
  };

  cfg = config.mymodules.programs.desktop.vscode;
in
{
  options.mymodules.programs.desktop.vscode = {
    enable = mkBoolOpt false;
    package = mkOption {
      default = pkgs.vscode;
      type = types.package;
    };
    extensions = mkOption {
      type = with types;
        listOf package;
      default = with pkgs.vscode-extensions; [
        vscodevim.vim
      ];
      description = lib.mdDoc "Extensions to be installed";
      example = "with pkgs; [ ntfs3g ]";
    };
    # userSettings = mkOption {
    #   inherit (jsonFormat) type;
    #   default = {
    #     vim = {
    #       insertModeKeyBindings = [
    #         {
    #           before = [ "j" "k" ];
    #           after = "<Esc>";
    #         }
    #       ];
    #       useSystemClipboard = true;
    #     };
    #   };
    #   description = lib.mdDoc "User settings";
    #   example = literalExpression '' {
    #   files.autoSave = "afterDelay",
    #   } '';
    # };
  };

  config = mkIf cfg.enable {
    home.packages = [ my-vscode ];

    mymodules.impermanence.cache = {
      directories = [
        ".config/Code"
        ".vscode"
      ];
    };
  };
}

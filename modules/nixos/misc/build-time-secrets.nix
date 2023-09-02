{ config, lib, mylib, mysecrets, ... }:
let
  inherit (lib) types;
  inherit (lib.options) mkOption;
  inherit (mylib) mkBoolOpt;

  secretType = types.submodule ({ config, ... }: {
    config = {
      buildSecretsFile = lib.mkOptionDefault cfg.defaultSecretsFile;
      #buildSecretsFileHash = lib.mkOptionDefault "${builtins.hashFile "sha256" config.buildTimeSecretsFile}";
      values = lib.mkOptionDefault (builtins.fromJSON (builtins.readFile config.buildSecretsFile));
    };
    options = {
      buildSecretsFile = mkOption {
        type = types.path;
        default = cfg.defaultSecretsFile;
      };
      #buildSecretsFileHash = mkOption {
      #  type = types.str;
      #  readOnly = true;
      #};
      values = mkOption {
        type = types.anything;
        readOnly = true;
      };
    };
  }
  );

  cfg = config.mymodules.buildTimeSecrets;
in
{
  options.mymodules.buildTimeSecrets = {
    enable = mkBoolOpt false;
    secrets = mkOption {
      type = types.attrsOf secretType;
      default = { };
    };

    default = mkOption {
      type = secretType;
      default = { };
    };

    defaultSecretsFile = mkOption {
      default = mysecrets + "/buildtime-secrets.json.crypt";
      type = types.path;
    };
  };

}

{ config, lib, mylib, inputs, ... }:
let
  inherit (lib) types;
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkOption;
  inherit (mylib) mkBoolOpt;

  inherit (inputs) sops-nix;

  cfg = config.modules.sops;
in
{
  imports = [ sops-nix.nixosModules.sops ];

  options.modules.sops = {
    enable = mkBoolOpt false;

    defaultSopsFile = mkOption {
      default = inputs.mysecrets + /default.sops.yaml;
      type = types.path;
    };
  };

  config = mkIf cfg.enable {
    sops = {
      inherit (cfg) defaultSopsFile;
      age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    };
  };
}

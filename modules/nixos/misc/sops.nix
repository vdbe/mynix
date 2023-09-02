{ config, lib, mylib, inputs, mysecrets, ... }:
let
  inherit (lib) types;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.options) mkOption;
  inherit (mylib) mkBoolOpt;

  inherit (config.mymodules) impermanence;

  cfg = config.mymodules.sops;
in
{
  imports = [ inputs.sops-nix.nixosModules.sops ];

  options.mymodules.sops = {
    enable = mkBoolOpt false;

    defaultSopsFile = mkOption {
      default = mysecrets + "/default.sops.yaml";
      type = types.path;
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      sops = {
        inherit (cfg) defaultSopsFile;
        #age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
        gnupg.sshKeyPaths = [ ];
        age.sshKeyPaths =
          if impermanence.enable
          then
            [ "${impermanence.location}/state/system/etc/ssh/ssh_host_ed25519_key" ]
          else
            [ "/etc/ssh/ssh_host_ed25519_key" ];
      };
    }
  ]);
}

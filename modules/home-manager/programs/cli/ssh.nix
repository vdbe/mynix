{ config, lib, mylib, myconfig, ... }:

let
  inherit (lib) types;
  inherit (lib.modules) mkDefault mkIf;
  inherit (lib.options) mkOption;
  inherit (mylib) mkBoolOpt;

  gp-gagent-sshSupport = config.mymodules.services.gpg-agent.enableSshSupport;

  cfg = config.mymodules.programs.cli.ssh;
in
{
  options.mymodules.programs.cli.ssh = {
    enable = mkBoolOpt false;
    localConfig = mkBoolOpt true;
    pgp = mkBoolOpt gp-gagent-sshSupport;
    controlMaster = mkOption {
      type = types.enum [ "no" "yes" "ask" "auto" "autoask" ];
      default = "no";
    };
  };

  config = mkIf cfg.enable {
    programs.ssh = {
      enable = mkDefault true;
      includes = mkIf cfg.localConfig [ "local_config" ];
      forwardAgent = false;
      inherit (cfg) controlMaster;
      controlPath = "/run/user/%i/ssh-controlmasters_%r@%h:%p";
      controlPersist = "10m";

      matchBlocks = {
        "*" = {
          forwardX11 = false;
          forwardX11Trusted = false;
          sendEnv = [ "Lang" "LC_*" ];
          identityFile = mkIf cfg.pgp [ "~/.ssh/pgp.pub" ];
          extraOptions = {
            AddKeysToAgent = "yes";
            IdentityAgent = mkIf gp-gagent-sshSupport "/run/user/%i/gnupg/S.gpg-agent.ssh";
          };
        };
      };
    };

    home.file.".ssh/pgp.pub".source = myconfig + "/ssh/pgp.pub";

    mymodules.impermanence.data.directories = [
      ".ssh"
    ];
  };
}

{ config, lib, mylib, myconfig, ... }:

let
  inherit (lib) lists;
  inherit (lib.modules) mkDefault mkIf mkMerge;
  inherit (mylib) mkBoolOpt;

  inherit (config.mymodules) impermanence;

  gp-gagent-sshSupport = config.mymodules.services.gpg-agent.enableSshSupport;

  cfg = config.mymodules.programs.cli.ssh;
in
{
  options.mymodules.programs.cli.ssh = {
    enable = mkBoolOpt false;
    localConfig = mkBoolOpt true;
    pgp = mkBoolOpt gp-gagent-sshSupport;
  };

  config = mkIf cfg.enable (mkMerge [
    {
      programs.ssh = {
        enable = mkDefault true;
        includes = lists.optional cfg.localConfig "local_config";
        forwardAgent = false;
        controlMaster = "auto";
        controlPath = "/run/user/%i/ssh-controlmasters_%r@%h:%p";
        controlPersist = "10m";
        extraConfig = ''
        '';

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
    }

    (mkIf impermanence.enable {
      home.persistence."${impermanence.location}/data/users/${config.home.username}" = {
        removePrefixDirectory = false;
        allowOther = true;
        directories = [
          ".ssh"
        ];
      };
    })
  ]);
}

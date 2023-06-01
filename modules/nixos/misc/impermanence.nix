{ config, lib, mylib, inputs, ... }:
let
  inherit (lib) types;
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkOption;
  inherit (mylib) mkBoolOpt;

  inherit (inputs) impermanence;

  cfg = config.mymodules.impermanence;
in
{
  imports = [
    impermanence.nixosModules.impermanence
  ];

  options.mymodules.impermanence = {
    enable = mkBoolOpt false;
    location = mkOption {
      default = "/persist";
      type = types.str;
    };
    hideMounts = mkBoolOpt true;
  };

  config = mkIf cfg.enable (
    let
      inherit (builtins) attrValues;
      inherit (lib.lists) forEach flatten;

      homeManagerUsers = config.home-manager.users;
      homeManagerUsersList = attrValues homeManagerUsers;
      users = forEach homeManagerUsersList
        (
          homeManagerUser:
          let
            user = config.users.users.${homeManagerUser.home.username};
            username = user.name;
            inherit (user) group;
          in
          { inherit username group; }
        );

      userRules = forEach users (user:
        let
          perm = "0755 ${user.username} ${user.group}";
        in
        [
          "d ${cfg.location}/data/users/${user.username} ${perm}"
          "d ${cfg.location}/cache/users/${user.username} ${perm}"
        ]);

      flatUserRules = flatten userRules;

      systemRules = [
        "d ${cfg.location}/data 0755 root root"
        "d ${cfg.location}/cache 0755 root root"
        "d ${cfg.location}/data/system 0755 root root"
        "d ${cfg.location}/cache/system 0755 root root"
      ];
    in
    {
      # TODO: Check if it is a filesystem before
      fileSystems.${cfg.location}.neededForBoot = true;

      systemd.tmpfiles.rules = systemRules ++ flatUserRules;

      programs.fuse.userAllowOther = true; # required for allowOther
      environment.persistence."${cfg.location}/data/system" = {
        inherit (cfg) hideMounts;
        directories = [
          "/var/log"
          "/var/lib/nixos"
          "/var/lib/systemd/coredump"
        ];

        files = [
          "/etc/machine-id"
          "/etc/ssh/ssh_host_rsa_key"
          "/etc/ssh/ssh_host_rsa_key.pub"
          "/etc/ssh/ssh_host_ed25519_key"
          "/etc/ssh/ssh_host_ed25519_key.pub"
        ];
      };
    }
  );
}

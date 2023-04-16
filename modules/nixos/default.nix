_:
let
  modules = [
    ./misc/nix.nix
    ./misc/sops.nix
    ./misc/yubikey.nix
    ./programs/cli/bash.nix
    ./programs/cli/fish.nix
    ./services/hardware/pcscd.nix
    ./services/hardware/pcscd.nix
    ./services/networking/sshd.nix
    ./services/security/fail2ban.nix
    ./virtualisation/xe-guest-utilities.nix
  ];

in
{
  imports = modules;
}

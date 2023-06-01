_:
let
  modules = [
    ./desktops/gnome.nix
    ./misc/impermanence.nix
    ./misc/nix-path.nix
    ./misc/nix.nix
    ./misc/sops.nix
    ./misc/yubikey.nix
    ./programs/cli/bash.nix
    ./programs/cli/fish.nix
    ./security/acme.nix
    ./services/display-managers/default.nix
    ./services/display-managers/gdm.nix
    ./services/hardware/pcscd.nix
    ./services/networking/sshd.nix
    ./services/security/fail2ban.nix
    ./services/x11/xserver.nix
    ./virtualisation/xe-guest-utilities.nix
  ];

in
{
  imports = modules;
}

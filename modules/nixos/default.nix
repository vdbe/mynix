_:
let
  modules = [
    ./desktops/gnome.nix
    ./misc/build-time-secrets.nix
    ./misc/impermanence.nix
    ./misc/nix-path.nix
    ./misc/nix.nix
    ./misc/sops.nix
    ./misc/yubikey.nix
    ./programs/cli/bash.nix
    ./programs/cli/fish.nix
    ./programs/firejail.nix
    ./security/acme.nix
    ./services/desktops/flatpak.nix
    ./services/desktops/pipewire.nix
    ./services/display-managers/default.nix
    ./services/display-managers/gdm.nix
    ./services/hardware/pcscd.nix
    ./services/networking/sshd.nix
    ./services/security/fail2ban.nix
    ./services/x11/xserver.nix
    ./virtualisation/docker.nix
    ./virtualisation/xe-guest-utilities.nix
  ];

in
{
  imports = modules;
}

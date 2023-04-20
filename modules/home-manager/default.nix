_:
let
  modules = [
    ./desktops/gnome.nix
    ./misc/nix-path.nix
    ./misc/nix.nix
    ./misc/xdg.nix
    ./programs/cli/bash.nix
    ./programs/cli/bat.nix
    ./programs/cli/bitwarden-cli.nix
    ./programs/cli/exa.nix
    ./programs/cli/fish.nix
    ./programs/cli/git.nix
    ./programs/cli/gpg.nix
    ./programs/cli/htop.nix
    ./programs/cli/starship.nix
    ./programs/cli/tmux.nix
    ./programs/desktop/browsers/firefox.nix
    ./services/gpg-agent.nix
  ];

in
{
  imports = modules;
}

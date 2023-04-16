_:
let
  modules = [
    ./programs/cli/bash.nix
    ./programs/cli/bat.nix
    ./programs/cli/bitwarden-cli.nix
    ./programs/cli/exa.nix
    ./programs/cli/fish.nix
    ./programs/cli/gpg.nix
    ./programs/cli/htop.nix
    ./programs/cli/starship.nix
    ./programs/cli/tmux.nix
    ./programs/cli/git.nix
    ./services/gpg-agent.nix
  ];

in
{
  imports = modules;
}

_:
let
  modules = [
    ./desktops/gnome.nix
    ./misc/impermanence.nix
    ./misc/nix-path.nix
    ./misc/nix.nix
    ./misc/xdg.nix
    ./programs/cli/bash.nix
    ./programs/cli/bat.nix
    ./programs/cli/bitwarden-cli.nix
    ./programs/cli/direnv.nix
    ./programs/cli/exa.nix
    ./programs/cli/fd.nix
    ./programs/cli/fish.nix
    ./programs/cli/fzf.nix
    ./programs/cli/git.nix
    ./programs/cli/gpg.nix
    ./programs/cli/htop.nix
    ./programs/cli/jq.nix
    ./programs/cli/lazygit.nix
    ./programs/cli/password-store.nix
    ./programs/cli/starship.nix
    ./programs/cli/tmux.nix
    ./programs/cli/translate.nix
    ./programs/desktop/browsers/firefox.nix
    ./services/gpg-agent.nix
  ];

in
{
  imports = modules;
}

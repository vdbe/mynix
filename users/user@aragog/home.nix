{ pkgs, ... }:
{
  imports = [
    # Based on the user user
    ./../user/home.nix
  ];

  # Let Home Manager install and manage itself.
  #programs.home-manager.enable = true;

  modules = {
    programs.cli = {
      bat.enable = true;
      exa.enable = true;
      git.enable = true;
      gpg.enable = true;
      htop.enable = true;
      starship.enable = true;
      tmux.enable = true;
    };
  };

  home = {
    packages = with pkgs; [ nload unstable.neovim my.maelstrom ];
  };
}

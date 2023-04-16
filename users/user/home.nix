{ pkgs, ... }:
{
  # Let Home Manager install and manage itself.
  #programs.home-manager.enable = true;

  modules = {
    programs.cli = {
      exa.enable = true;
      htop.enable = true;
      starship.enable = true;
      tmux.enable = true;
    };
  };

  home = {
    packages = with pkgs; [ ];
  };
}

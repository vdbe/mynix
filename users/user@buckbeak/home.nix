{ pkgs, ... }:
{
  imports = [
    # Based on the user user
    ./../user/home.nix
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  modules = {
    nix.enable = true;
    nix-path = {
      enable = true;
      overlays.enable = true;
    };
    programs.cli = {
      fish.enable = true;
      bat.enable = true;
      exa.enable = true;
      starship.enable = true;
      tmux.enable = true;
    };
  };

  home = {
    packages = with pkgs; [ ];
  };
}

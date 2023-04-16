{ pkgs, ... }:
let username = "user";
in
{
  #imports = [ ./../home.nix ];


  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.

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

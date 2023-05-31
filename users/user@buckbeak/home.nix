{ pkgs, ... }:
{
  imports = [
    # Based on the user user
    #./../user/home.nix
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  mymodules = {
    nix.enable = true;
    nix-path = {
      enable = true;
      overlays.enable = true;
    };
    programs.cli = {
      bat.enable = true;
      exa.enable = true;
      fd.enable = true;
      fish.enable = true;
      fzf.enable = true;
      git.enable = true;
      gpg.enable = true;
      starship.enable = true;
      tmux.enable = true;
    };
  };

  programs = {
    # gpg module was enabled to get gpg integration with other modules
    # not to setup gpg, so we disable the program.
    gpg.enable = false;
  };


  home = {
    packages = with pkgs.unstable; [
      direnv
      lazygit
      nix
      nix-direnv
      nix-tree
    ];
  };
}

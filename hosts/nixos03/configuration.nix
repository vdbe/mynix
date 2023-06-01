{ self, config, pkgs, lib, mylib, inputs, system, ... }:

let
  inherit (mylib) mkExtraSpecialArgs;
in
{
  imports = [
    ./hardware.nix

    inputs.home-manager.nixosModules.home-manager
  ];

  mymodules = {
    impermanence.enable = true;
    services = {
      openssh.enable = true;
      xe-guest-utilities.enable = true;
    };
    sops.enable = true;
    nix.enable = true;
    nix-path.enable = true;
    programs.cli = {
      fish.enable = true;
      bash.enable = true;
    };
  };

  users.users.user = {
    isNormalUser = true;
    shell = pkgs.fish;
    password = "toor123";
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBB774/7KJ/Y5k9jVF8YACJiyPKzU4PZs3brXbnMHtmq user@buckbeak"
    ];

    # packages = with pkgs; [
    #   firefox
    #   thunderbird
    # ];
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;


  security.sudo.extraRules = [
    {
      users = [ "user" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ]; # "SETENV" # Adding the following could be a good idea
        }
      ];
    }
  ];

  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    users.user = {
      imports = [
        (inputs.myhomemanager + /home.nix)
        (inputs.myhomemanager + /user/home.nix)
      ];

      mymodules = {
        programs.cli = {
          bat.enable = true;
          direnv.enable = true;
          exa.enable = true;
          fd.enable = true;
          fish.enable = true;
          fzf.enable = true;
          git.enable = true;
          gpg = {
            enable = true;
            mutableTrust = true;
          };
          jq.enable = true;
          lazygit.enable = true;
          password-store.enable = true;
          starship.enable = true;
          tmux.enable = true;
          translate.enable = true;
        };
      };
    };
    extraSpecialArgs = mkExtraSpecialArgs config {
      inherit self lib mylib pkgs inputs system;
    };
  };
}


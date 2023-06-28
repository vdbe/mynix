args@{ config, pkgs, mylib, inputs, ... }:

let
  inherit (mylib) mkExtraSpecialArgs;
in
{
  imports = [
    ./hardware.nix

    inputs.home-manager.nixosModules.home-manager
  ];

  mymodules = {
    services = {
      openssh.enable = true;
      fail2ban.enable = true;
      xe-guest-utilities.enable = true;
    };
    sops.enable = true;
    nix.enable = true;
    nix-path.enable = true;
    yubikey.enable = true;
    programs.cli = {
      bash.enable = true;
      fish.enable = true;
    };
  };

  users.users.user = {
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBB774/7KJ/Y5k9jVF8YACJiyPKzU4PZs3brXbnMHtmq user@buckbeak"
    ];

    # packages = with pkgs; [
    #   firefox
    #   thunderbird
    # ];
  };

  environment.systemPackages = [ config.services.headscale.package ];


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
    };
    extraSpecialArgs = mkExtraSpecialArgs config args;
  };
}


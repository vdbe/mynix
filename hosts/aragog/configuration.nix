args@{ config, pkgs, mylib, inputs, ... }:

let
  inherit (mylib) mkExtraSpecialArgs;
in
{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware.nix

      inputs.nixos-hardware.nixosModules.common-cpu-amd
      inputs.nixos-hardware.nixosModules.common-pc-laptop
      inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd
      inputs.nixos-hardware.nixosModules.common-pc-laptop-acpi_call

      inputs.home-manager.nixosModules.home-manager
    ];
  sops.secrets.hashed_password.neededForUsers = true;

  mymodules = {
    sops.enable = true;
    buildTimeSecrets = {
      enable = true;
      defaultSecretsFile = ./buildtime-secrets.json.crypt;
    };
    nix.enable = true;
    nix-path = {
      enable = true;
      overlays.enable = true;
    };
    yubikey.enable = true;
    services = {
      openssh.enable = true;
      fail2ban.enable = true;
    };
    programs = {
      cli = {
        fish.enable = true;
        bash.enable = true;
      };
    };
    desktops = {
      gnome.enable = true;
    };
    impermanence.enable = true;
  };


  networking = {
    networkmanager.enable = true;
  };

  # environment.systemPackages = with pkgs; [
  # ];

  users.users.user = {
    isNormalUser = true;
    passwordFile = config.sops.secrets.hashed_password.path;
    #initialPassword = "toor123";
    shell = pkgs.fish;
    extraGroups = [ "wheel" "networkmanager" "video" ]; # Enable ‘sudo’ for the user.
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBB774/7KJ/Y5k9jVF8YACJiyPKzU4PZs3brXbnMHtmq user@buckbeak"
    ];

    # packages = with pkgs; [
    # ];
  };
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBB774/7KJ/Y5k9jVF8YACJiyPKzU4PZs3brXbnMHtmq user@buckbeak"
  ];

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
        (inputs.myhomemanager + "/user@${config.networking.hostName}/home.nix")
      ];
    };

    extraSpecialArgs = mkExtraSpecialArgs config args;
  };
}

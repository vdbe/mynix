{ self, config, pkgs, lib, mylib, inputs, system, ... }:

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

  modules = {
    sops.enable = true;
    nix.enable = true;
    yubikey.enable = true;
    services = {
      openssh.enable = true;
      fail2ban.enable = true;
    };
    programs.cli = {
      fish.enable = true;
      bash.enable = true;
    };
  };


  networking = {
    networkmanager.enable = true;
  };

  environment.systemPackages = with pkgs; [
  ];

  users.users.user = {
    isNormalUser = true;
    passwordFile = config.sops.secrets.hashed_password.path;
    shell = pkgs.fish;
    extraGroups = [ "wheel" "networkmanager" "video" ]; # Enable ‘sudo’ for the user.
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBB774/7KJ/Y5k9jVF8YACJiyPKzU4PZs3brXbnMHtmq user@buckbeak"
    ];

    packages = with pkgs; [
      # firefox
      # thunderbird
    ];
  };

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

  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    users.user = {
      imports = [
        (inputs.myhomemanager + /home.nix)
        (inputs.myhomemanager + "/user@${config.networking.hostName}/home.nix")
      ];
    };

    extraSpecialArgs = mkExtraSpecialArgs config {
      inherit self lib mylib pkgs inputs system;
    };
  };
}

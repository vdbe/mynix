{ inputs, ... }:

{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];


  networking.useDHCP = true;

  users = {
    mutableUsers = true;
    users.user = {
      isNormalUser = true;
      initialPassword = "password";
      extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBB774/7KJ/Y5k9jVF8YACJiyPKzU4PZs3brXbnMHtmq user@buckbeak"
      ];

      #packages = with pkgs; [
      #];
    };
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

  #home-manager = {
  #  useUserPackages = true;
  #  useGlobalPkgs = true;
  #  users.user = {
  #    imports = [
  #      (inputs.myhomemanager + /home.nix)
  #      (inputs.myhomemanager + /user/home.nix)
  #    ];
  #  };
  #  extraSpecialArgs = mkExtraSpecialArgs config {
  #    inherit self lib mylib pkgs inputs system;
  #  };
  #};
}


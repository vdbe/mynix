{ self, config, lib, ... }:

let
  inherit (lib.attrsets) attrByPath;
  inherit (lib.modules) mkDefault mkIf;
in
{
  imports = [
    self.nixosModules.default
  ];

  boot = {
    loader = {
      efi.canTouchEfiVariables = mkDefault true;
      systemd-boot = {
        enable = mkDefault true;
        configurationLimit = mkDefault 10;
      };
    };
    tmp = {
      useTmpfs = mkDefault true;
    };
  };

  # Only set if disko is not enabled
  fileSystems = mkIf (!(attrByPath [ "disko" "enableConfig" ] false config)) {
    "/" = mkDefault {
      device = "/dev/disk/by-label/NIXOS";
    };
  };

  time.timeZone = mkDefault "Europe/Brussels";
  i18n.defaultLocale = mkDefault "en_US.UTF-8";
  nix.nixPath = mkDefault [ ];

  networking = {
    firewall.enable = mkDefault true;
    useDHCP = mkDefault false;
    dhcpcd.wait = "background";
  };

  environment = {
    #binsh = "${pkgs.dash}/bin/dash";
    #localBinInPath = true;

    #systemPackages = with pkgs; [ dash ];
  };

  programs.command-not-found.enable = mkDefault false;

  users = {
    mutableUsers = mkDefault false;
    users = {
      root = {
        #hashedPassword = "*";
      };
    };
  };

  system = {
    configurationRevision = mkDefault (self.rev or "dirty");
    stateVersion = mkDefault "23.05";
  };
}

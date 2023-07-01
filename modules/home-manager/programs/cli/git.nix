{ config, lib, mylib, ... }:

let
  inherit (lib.attrsets) optionalAttrs;
  inherit (lib.modules) mkIf;
  inherit (mylib) mkBoolOpt;

  cfg = config.mymodules.programs.cli.git;

  aliases = { } // optionalAttrs cfg.enableAliases {
    root = "rev-parse --show-toplevel";

    exec = "!exec ";
    r = "!exec ";

    lc = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(auto)%d%C(reset)' --all";
    lg = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(bold cyan)%aD%C(reset) %C(bold yellow)%d%C(reset)%n'' %C(white)%s%C(reset) %C(dim white)- %an (%ae)%C(reset)' --all";
  };

  shellAliases = { } // optionalAttrs cfg.enableShellAliases {
    gcd = "cd \"$(git root)\"";
  };

  shellAbbrs = { } // optionalAttrs cfg.enableShellAliases {
    g = "git";
  };
in
{
  options.mymodules.programs.cli.git = {
    enable = mkBoolOpt false;
    enableAliases = mkBoolOpt true;
    enableShellAliases = mkBoolOpt true;

    # TODO: extract userName/userEmail and signing into options
  };

  config = mkIf cfg.enable {
    programs = {
      git = {
        enable = true;
        inherit aliases;
        extraConfig = {
          init = { defaultBranch = "main"; };
        };

      } // optionalAttrs config.mymodules.programs.cli.gpg.enable {
        userName = "vdbewout";
        userEmail = "vdbewout@gmail.com";

        signing = {
          key = "482AEE74BFCFD294EBBB4A247019E6C8EFE72BF0";
          signByDefault = true;
        };
      };

      fish = {
        inherit shellAbbrs;
      };
    };
    home.shellAliases = shellAliases // shellAbbrs;
  };
}

{
  self,
  pkgs,
  inputs,
  lib,
  ...
}:
{
  imports = [
    ../shared/machine-name.nix
    ./window-manager.nix
  ];

  # TEMP FIX
  system = {
    primaryUser = "loicweber";
    configurationRevision = self.rev or self.dirtyRev or null;
    # Used for backwards compatibility, please read the changelog before changing.
    # $ darwin-rebuild changelog
    stateVersion = 4;
  };

  ids.gids.nixbld = lib.mkForce 350;

  nix = {
    enable = true;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
    optimise.automatic = true;
  };

  environment.systemPackages = [
    inputs.justnixvim.packages."aarch64-darwin".default
    pkgs.colima
    pkgs.docker-credential-helpers
  ];

  homebrew.enable = false;

  environment.systemPath = [
    "/opt/homebrew/bin"
    "/opt/homebrew/sbin"
  ];

  # system.configurationRevision and stateVersion are set in the system block above

  users = {
    users.loicweber = {
      home = "/Users/loicweber/";
    };
  };

  programs.direnv = {
    enable = true;
    settings = {
      global = {
        load_dotenv = true;
      };
    };
  };

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";

  machineName = "owl";
}

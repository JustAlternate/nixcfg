{
  self,
  inputs,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./window-manager.nix
  ];

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
  ];

  # Create /etc/zshrc that loads the nix-darwin environment.
  # programs.zsh.enable = true;

  # Set Git commit hash for darwin-version.
  system.configurationRevision = self.rev or self.dirtyRev or null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  users.users.loicweber = {
    home = "/Users/loicweber/";
  };

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";
}

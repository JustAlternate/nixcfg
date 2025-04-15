{
  self,
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    ./window-manager.nix
  ];

  nix = {
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

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  # nix.package = pkgs.nix;

  # Create /etc/zshrc that loads the nix-darwin environment.
  # programs.zsh.enable = true;

  # Set Git commit hash for darwin-version.
  system.configurationRevision = self.rev or self.dirtyRev or null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";

  users.users.loicweber = {
    home = "/Users/loicweber";
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs pkgs; };

    users.loicweber =
      { pkgs, ... }:
      {
        # Define module here
        # Explicitly set these:
        home.homeDirectory = "/Users/loicweber";
        home.username = "loicweber";

        # Import your actual home config:
        imports = [
          ./home/default.nix # Make sure this path is correct!
        ];
      };
  };
}

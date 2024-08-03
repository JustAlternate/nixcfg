{
  description = "Nixos config flake";

  inputs = {

    # nixpkgs
    nixpkgs.url = "nixpkgs/nixos-24.05";
    master.url = "github:nixos/nixpkgs/master";

    # home-manager
    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # other urls
    hyprland.url = "github:hyprwm/Hyprland";
    hyprland-plugins = {
        url = "github:hyprwm/hyprland-plugins";
        inputs.hyprland.follows = "hyprland"; # IMPORTANT
    };
  };

  outputs = { self, nixpkgs, master, home-manager, ... } @ inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {

    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [ 
          ./nixos/configuration.nix
	  home-manager.nixosModules.home-manager
        ];
      };
    };
    homeConfigurations = {
      justalternate = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./home-manager/home.nix
        ];
        extraSpecialArgs = {
          inherit inputs;
        };
      };
    };
  };
}

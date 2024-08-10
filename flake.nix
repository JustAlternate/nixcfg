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
    lobster.url = "github:justchokingaround/lobster";
  };

  outputs = {
    self,
    nixpkgs,
    master,
    home-manager,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    nixosConfigurations = {
      LaptopNixos = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./laptop_nix/configuration.nix
          home-manager.nixosModules.home-manager
        ];
      };
    };
    homeConfigurations = {
      justalternate = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./home
        ];
        extraSpecialArgs = {
          inherit inputs;
        };
      };
    };
  };
}

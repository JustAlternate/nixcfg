{
  description = "Nixos config flake";

  inputs = {
    # nixpkgs
    nixpkgs.url = "nixpkgs/nixos-24.05";
    nixos-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    # home-manager
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # sops
    sops-nix.url = "github:Mic92/sops-nix";
    # optional, not necessary for the module
    #sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    # other urls
    lobster.url = "github:justchokingaround/lobster";
    themecord = {
      url = "github:danihek/themecord";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-gaming.url = "github:fufexan/nix-gaming";

  };


  outputs =
    { nixpkgs
    , home-manager
    , nixos-unstable
    , sops-nix
    , ...
    } @ inputs:
    let
      system = "x86_64-linux";
      systemMac = "aarch64-darwin";
      systemArm = "aarch64-linux";
      nixos-overlays = [
        # Allow configurations to use pkgs.unstable.<package-name>.
        (_: prev: {
          unstable = import nixos-unstable {
            inherit (prev) system;
            config.allowUnfree = true;
          };
        })
      ];
    in
    {
      # NixOS configurations
      nixosConfigurations = {
        ParrotNixos = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            ./Parrot/configuration.nix
            home-manager.nixosModules.home-manager
            sops-nix.nixosModules.sops
          ];
        };
        SwordfishNixos = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            ./Swordfish/configuration.nix
            home-manager.nixosModules.home-manager
            sops-nix.nixosModules.sops
          ];
        };
        BeaverNixos = nixpkgs.lib.nixosSystem {
          system = systemArm;
          specialArgs = { inherit inputs; };
          modules = [
            ./Beaver/configuration.nix
            home-manager.nixosModules.home-manager
            sops-nix.nixosModules.sops
          ];
        };
      };
      # Nix Home-manger configurations
      homeConfigurations = {
        parrot = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          modules = [
            { nixpkgs.overlays = nixos-overlays; }
            ./Parrot/home
          ];
          extraSpecialArgs = {
            inherit inputs;
          };
        };
        swordfish = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          modules = [
            { nixpkgs.overlays = nixos-overlays; }
            ./Swordfish/home
          ];
          extraSpecialArgs = {
            inherit inputs;
          };
        };
        beaver = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${systemArm};
          modules = [
            ./Beaver/home
          ];
          extraSpecialArgs = {
            inherit inputs;
          };
        };
        owl = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${systemMac};
          modules = [
            ./Owl
          ];
          extraSpecialArgs = {
            inherit inputs;
          };
        };
      };
    };
}

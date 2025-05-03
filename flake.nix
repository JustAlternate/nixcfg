{
  description = "Nixos config flake";

  inputs = {
    # nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixos-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable"; # LEGACY FOR OWL
    master.url = "github:nixos/nixpkgs/master";

    justnixvim.url = "github:JustAlternate/justnixvim";

    # home-manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # sops
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # For nix-darwin for Owl
    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nixos-unstable,
      master,
      nix-darwin,
      ...
    }@inputs:
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
        # Allow configurations to use pkgs.master.<package-name>.
        (_: prev: {
          master = import master {
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
          modules = [
            ./Parrot/configuration.nix
            home-manager.nixosModules.home-manager
            inputs.sops-nix.nixosModules.sops
            { nixpkgs.overlays = nixos-overlays; }
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.justalternate = import ./Parrot/home;
                extraSpecialArgs = {
                  inherit inputs;
                };
              };
            }
          ];
        };
        SwordfishNixos = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs;
          };
          modules = [
            ./Swordfish/configuration.nix
            home-manager.nixosModules.home-manager
            inputs.sops-nix.nixosModules.sops
            { nixpkgs.overlays = nixos-overlays; }
          ];
        };
        BeaverNixos = nixpkgs.lib.nixosSystem {
          system = systemArm;
          modules = [
            ./Beaver/configuration.nix
            home-manager.nixosModules.home-manager
            inputs.sops-nix.nixosModules.sops
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.justalternate = import ./Beaver/home;
                extraSpecialArgs = {
                  inherit inputs;
                };
              };
            }
          ];
        };
        GeckoNixos1 = nixpkgs.lib.nixosSystem {
          system = systemArm;
          specialArgs = {
            inherit inputs;
          };
          modules = [ ./Gecko/hardware-configuration-pi3b+.nix ];
        };
        GeckoNixos2 = nixpkgs.lib.nixosSystem {
          system = systemArm;
          specialArgs = {
            inherit inputs;
          };
          modules = [ ./Gecko/hardware-configuration-pi4.nix ];
        };
      };

      # Nix Home-manger configurations
      homeConfigurations = {
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
      };

      # Nix-darwin configurations
      darwinConfigurations."Owl" = nix-darwin.lib.darwinSystem {
        system = systemMac;
        specialArgs = {
          inherit inputs self;
        };
        modules = [
          home-manager.darwinModules.home-manager
          { nixpkgs.overlays = nixos-overlays; }
          ./Owl/configuration.nix
        ];
      };
    };

}

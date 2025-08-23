{
  description = "Nixos config flake";

  inputs = {
    # nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";

    unstable-nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    justnixvim.url = "github:JustAlternate/justnixvim";

    # home-manager
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # sops
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # For nix-darwin for owl
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      unstable-nixpkgs,
      home-manager,
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
          unstable = import unstable-nixpkgs {
            inherit (prev) system;
            config.allowUnfree = true;
          };
        })
      ];
    in
    {
      # NixOS configurations
      nixosConfigurations = {
        parrotNixos = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./parrot/configuration.nix
            home-manager.nixosModules.home-manager
            inputs.sops-nix.nixosModules.sops
            { nixpkgs.overlays = nixos-overlays; }
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.justalternate = import ./parrot/home;
                extraSpecialArgs = {
                  inherit inputs;
                };
              };
            }
          ];
        };
        swordfishNixos = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./swordfish/configuration.nix
            home-manager.nixosModules.home-manager
            inputs.sops-nix.nixosModules.sops
            { nixpkgs.overlays = nixos-overlays; }
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.justalternate = import ./swordfish/home;
                extraSpecialArgs = {
                  inherit inputs;
                };
              };
            }
          ];
        };
        beaverNixos = nixpkgs.lib.nixosSystem {
          system = systemArm;
          modules = [
            ./beaver/configuration.nix
            home-manager.nixosModules.home-manager
            inputs.sops-nix.nixosModules.sops
            { nixpkgs.overlays = nixos-overlays; }
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.root = import ./beaver/home;
                extraSpecialArgs = {
                  inherit inputs;
                };
              };
            }
          ];
        };
        geckoNixos1 = nixpkgs.lib.nixosSystem {
          system = systemArm;
          specialArgs = {
            inherit inputs;
          };
          modules = [ ./gecko/hardware-configuration-pi3b+.nix ];
        };
        geckoNixos2 = nixpkgs.lib.nixosSystem {
          system = systemArm;
          specialArgs = {
            inherit inputs;
          };
          modules = [ ./gecko/hardware-configuration-pi4.nix ];
        };
      };

      # Nix-darwin configurations
      darwinConfigurations."owl" = nix-darwin.lib.darwinSystem {
        system = systemMac;
        specialArgs = {
          inherit inputs self;
        };
        modules = [
          home-manager.darwinModules.home-manager
          ./owl/configuration.nix
          { nixpkgs.overlays = nixos-overlays; }
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.loicweber = import ./owl/home;
              extraSpecialArgs = {
                inherit inputs;
              };
            };
          }
        ];
      };
    };

}

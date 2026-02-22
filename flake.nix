{
  description = "Nixos config flake";

  inputs = {
    # nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";

    unstable-nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    master-nixpkgs.url = "github:nixos/nixpkgs/master";

    justnixvim.url = "github:JustAlternate/justnixvim";

    # home-manager
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
      url = "github:hyprwm/Hyprland/v0.53.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # sops
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # For nix-darwin for owl
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mistral-vibe.url = "github:mistralai/mistral-vibe";

    nixos-mailserver = {
      url = "gitlab:simple-nixos-mailserver/nixos-mailserver/nixos-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      unstable-nixpkgs,
      master-nixpkgs,
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
          master = import master-nixpkgs {
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
          specialArgs = { inherit inputs; };
          inherit system;
          modules = [
            ./hosts/parrot/system
            home-manager.nixosModules.home-manager
            inputs.sops-nix.nixosModules.sops
            { nixpkgs.overlays = nixos-overlays; }
            (
              { config, ... }:
              {
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  users.justalternate = import ./hosts/parrot/home;
                  extraSpecialArgs = {
                    inherit inputs;
                    machineName = config.machineName or "parrot";
                  };
                };
              }
            )
          ];
        };
        swordfishNixos = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          inherit system;
          modules = [
            ./hosts/swordfish/system
            home-manager.nixosModules.home-manager
            inputs.sops-nix.nixosModules.sops
            { nixpkgs.overlays = nixos-overlays; }
            (
              { config, ... }:
              {
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  backupFileExtension = "backup";
                  users.justalternate = import ./hosts/swordfish/home;
                  extraSpecialArgs = {
                    inherit inputs;
                    machineName = config.machineName or "swordfish";
                  };
                };
              }
            )
          ];
        };
        beaverNixos = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          system = systemArm;
          modules = [
            ./hosts/beaver/system
            home-manager.nixosModules.home-manager
            inputs.sops-nix.nixosModules.sops
            { nixpkgs.overlays = nixos-overlays; }
            (
              { config, ... }:
              {
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  users.root = import ./hosts/beaver/home;
                  extraSpecialArgs = {
                    inherit inputs;
                    machineName = config.machineName or "beaver";
                  };
                };
              }
            )
          ];
        };
        geckoNixos1 = nixpkgs.lib.nixosSystem {
          system = systemArm;
          specialArgs = {
            inherit inputs;
          };
          modules = [ ./hosts/gecko/hardware-pi3b+.nix ];
        };
        geckoNixos2 = nixpkgs.lib.nixosSystem {
          system = systemArm;
          specialArgs = {
            inherit inputs;
          };
          modules = [ ./hosts/gecko/hardware-pi4.nix ];
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
          ./hosts/owl/system
          { nixpkgs.overlays = nixos-overlays; }
          (
            { config, ... }:
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.loicweber = import ./hosts/owl/home;
                extraSpecialArgs = {
                  inherit inputs;
                  machineName = config.machineName or "owl";
                };
              };
            }
          )
        ];
      };
    };

}

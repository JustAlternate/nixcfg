{
  description = "Nixos config flake";

  inputs = {
    # nixpkgs
    nixpkgs.url = "nixpkgs/nixos-24.11";
    nixos-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    # home-manager
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim/nixos-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # sops
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # For nix-darwin for Owl
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

    # other urls
    # lobster.url = "github:justchokingaround/lobster";
    themecord = {
      url = "github:danihek/themecord";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # For installing osu and osu-lazer
    nix-gaming.url = "github:fufexan/nix-gaming";

    nix-minecraft.url = "github:Infinidoge/nix-minecraft";
    # Minecraft servers

  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nixos-unstable,
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
      ];
    in
    {
      # NixOS configurations
      nixosConfigurations = {
        ParrotNixos = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs;
          };
          modules = [
            ./Parrot/configuration.nix
            home-manager.nixosModules.home-manager
            inputs.sops-nix.nixosModules.sops
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
          specialArgs = {
            inherit inputs;
          };
          modules = [
            ./Beaver/configuration.nix
            home-manager.nixosModules.home-manager
            inputs.sops-nix.nixosModules.sops
            { nixpkgs.overlays = nixos-overlays; }
          ];
        };
        # GeckoNixos = nixpkgs.lib.nixosSystem {
        #   system = systemArm;
        #   specialArgs = {
        #     inherit inputs;
        #   };
        #   modules = [ ./Gecko/default.nix ];
        # };
      };

      # Nix Home-manger configurations
      homeConfigurations = {
        parrot = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          modules = [
            { nixpkgs.overlays = nixos-overlays; }
            inputs.nixvim.homeManagerModules.nixvim
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
            inputs.nixvim.homeManagerModules.nixvim
            ./Swordfish/home
          ];
          extraSpecialArgs = {
            inherit inputs;
          };
        };
        beaver = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${systemArm};
          modules = [ ./Beaver/home ];
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
          inputs.nix-homebrew.darwinModules.nix-homebrew
          inputs.nixvim.nixDarwinModules.nixvim
          home-manager.darwinModules.home-manager
          { nixpkgs.overlays = nixos-overlays; }
          ./Owl/configuration.nix
        ];
      };
    };
}

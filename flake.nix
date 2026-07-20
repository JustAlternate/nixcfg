{
  description = "Nixos config flake";

  inputs = {
    # nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";

    unstable-nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    master-nixpkgs.url = "github:nixos/nixpkgs/master";
    my-nixpkgs.url = "github:JustAlternate/nixpkgs/master";

    justnixvim.url = "github:JustAlternate/justnixvim";

    fleettui.url = "github:JustAlternate/fleettui";

    # home-manager
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "unstable-nixpkgs";
    };

    # sops
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # For nix-darwin for owl
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mistral-vibe.url = "github:mistralai/mistral-vibe";

    nixos-mailserver = {
      url = "gitlab:simple-nixos-mailserver/nixos-mailserver/nixos-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-cli = {
      url = "github:nix-community/nixos-cli";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      unstable-nixpkgs,
      master-nixpkgs,
      my-nixpkgs,
      home-manager,
      nix-darwin,
      nixos-cli,
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
            system = prev.stdenv.hostPlatform.system;
            config.allowUnfree = true;
          };
          master = import master-nixpkgs {
            system = prev.stdenv.hostPlatform.system;
            config.allowUnfree = true;
          };
          my = import my-nixpkgs {
            system = prev.stdenv.hostPlatform.system;
            config.allowUnfree = true;
          };
        })
      ];

      # Standard host: NixOS + home-manager + sops + overlays.
      mkHost =
        {
          system,
          hostname,
          hmUser ? "justalternate",
          hmExtraConfig ? { },
        }:
        nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          inherit system;
          modules = [
            nixos-cli.nixosModules.nixos-cli
            ./hosts/${hostname}/system
            home-manager.nixosModules.home-manager
            inputs.sops-nix.nixosModules.sops
            { nixpkgs.overlays = nixos-overlays; }
            (
              { config, ... }:
              {
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  users.${hmUser} = import ./hosts/${hostname}/home;
                  extraSpecialArgs = {
                    inherit inputs;
                    machineName = config.machineName or hostname;
                  };
                }
                // hmExtraConfig;
              }
            )
          ];
        };

      # Lightweight gecko (Raspberry Pi) nodes: no home-manager/overlays.
      mkGecko =
        hostFile:
        nixpkgs.lib.nixosSystem {
          system = systemArm;
          specialArgs = { inherit inputs; };
          modules = [
            hostFile
            inputs.sops-nix.nixosModules.sops
          ];
        };
    in
    {
      # NixOS configurations
      nixosConfigurations = {
        parrotNixos = mkHost {
          inherit system;
          hostname = "parrot";
        };
        swordfishNixos = mkHost {
          inherit system;
          hostname = "swordfish";
          hmExtraConfig.backupFileExtension = "backup";
        };
        beaverNixos = mkHost {
          system = systemArm;
          hostname = "beaver";
          hmUser = "root";
        };

        geckoNixos1 = mkGecko ./hosts/gecko/geckoNixos1.nix;
        geckoNixos2 = mkGecko ./hosts/gecko/geckoNixos2.nix;
        geckoNixos3 = mkGecko ./hosts/gecko/geckoNixos3.nix;
        geckoNixos4 = mkGecko ./hosts/gecko/geckoNixos4.nix;
        geckoNixosRPISdImage = mkGecko ./hosts/gecko/geckoNixosRPI-sd-image.nix;
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

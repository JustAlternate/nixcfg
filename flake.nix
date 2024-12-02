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
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    # For nix-darwin for Owl
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
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
        GeckoNixos = nixpkgs.lib.nixosSystem {
          system = systemArm;
          specialArgs = {
            inherit inputs;
          };
          modules = [ ./Gecko/configuration-pi3b+.nix ];
        };
      };

      # Usage with deploy-rs
      deploy = {
        sshUser = "root"; # SSH login username
        user = "root"; # Remote username
        sshOpts = [
          "-p"
          "22"
        ];

        # Auto rollback on deployment failure, recommended off.
        #
        # NixOS deployment can be a bit flaky (especially on unstable)
        # and you may need to deploy twice to succeed, but auto rollback
        # works against that and make your deployments constantly fail.
        autoRollback = false;

        # Auto rollback on Internet disconnection, recommended off.
        #
        # Rollback when your new config killed the Internet connection,
        # so you don't have to use VNC or IPMI from your service provider.
        # But if you're adjusting firewall or IP settings, chances are
        # although the Internet is down atm, a simple reboot will make everything work.
        # Magic rollback works against that, so you should keep that off.
        magicRollback = false;

        nodes = {
          "BeaverNixos" = {
            # Target node's address, either IP, domain, or .ssh/config alias
            hostname = "justalternate.fr";
            profiles.system = {
              # Use nixosConfigurations."nixos" defined above
              path = inputs.deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.BeaverNixos;
            };
          };
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
          modules = [ ./Beaver/home ];
          extraSpecialArgs = {
            inherit inputs;
          };
        };
      };

      # Nix-darwin
      darwinConfigurations."Owl" = nix-darwin.lib.darwinSystem {
        system = systemMac;
        specialArgs = {
          inherit inputs self;
        };
        modules = [
          inputs.nix-homebrew.darwinModules.nix-homebrew
          home-manager.darwinModules.home-manager
          { nixpkgs.overlays = nixos-overlays; }
          ./Owl/configuration.nix
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.loicweber = import ./Owl/home;
            };

            # Optionally, use home-manager.extraSpecialArgs to pass
            # arguments to home.nix
          }
        ];
      };
    };
}

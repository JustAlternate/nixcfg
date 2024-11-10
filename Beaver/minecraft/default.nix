{ pkgs, inputs, ... }:
{
  imports = [ inputs.nix-minecraft.nixosModules.minecraft-servers ];
  nixpkgs.overlays = [ inputs.nix-minecraft.overlay ];

  environment = {
    systemPackages = with pkgs; [ tmux ];
  };

  services.minecraft-servers = {
    enable = true;
    eula = true; # Automatically accept eula
    dataDir = "/srv/minecraft";
    runDir = "/srv/minecraft";
    servers = {
      fallen-kingdom = {
        enable = false;
        autoStart = true; # Start on boot
        openFirewall = true; # Open port specified in the serverProperties config

        # Spin of the minecraft server to use and version (using unstable nixos branch to get latest papermc version)
        package = pkgs.unstable.papermcServers.papermc-1_21;

        serverProperties = {
          # A list can be found here : https://minecraft.wiki/w/Server.properties
          motd = "Fallen Kingdom minecraft server powered by NixOS!";
          server-port = 25565;
          difficulty = 2;
          gamemode = 1;
          max-players = 10;
          white-list = false;
          enable-command-block = true;
          view-distance = 16;
          simulation-distance = 8;
          spawn-animals = true;
          spawn-monsters = true;
          spawn-npcs = true;
          online-mode = false; # Accept crack player
        };

        # Performance jvm flags
        jvmOpts = "-Xms2G -Xmx6G -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1";

        whitelist = {
          JustAlternate = "8a3f19cf-9927-3b67-b784-4967c6d0005e";
        };

        # symlinks can be used to manage declaratively other files such as plugins, mods...
        symlinks = {
          # Mandatory paper config file
          "spigot.yml" = ./spigot.yml; # use the spigot.yml file in this folder for production
          "bukkit.yml" = ./bukkit.yml;

          # Plugins fetch and configuration
          "plugins/FallenKingdom.jar" = pkgs.fetchurl rec {
            pname = "FallenKingdom";
            version = "2.23.2";
            url = "https://cdn.modrinth.com/data/wKYpobLb/versions/8oEbkpgh/${pname}-${version}.jar";
            hash = "sha256-6vL1k0uy/dLg9NncYWe3QS98XwVF39MAqYiWXtoYfAc=";
          };
          "plugins/FallenKingdom/config.yml" = ./plugins/FallenKingdom/config.yml;

          "plugins/SkinsRestorer.jar" = pkgs.fetchurl {
            pname = "SkinsRestorer";
            url = "https://objects.githubusercontent.com/github-production-release-asset-2e65be/105874986/e2327cac-01ef-48e8-a41a-778d71fa6f32?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=releaseassetproduction%2F20241105%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20241105T175629Z&X-Amz-Expires=300&X-Amz-Signature=1bf1f3ff6668115ee1e6eb708da732961802d78d0b2c4200d56e89255fd5654a&X-Amz-SignedHeaders=host&response-content-disposition=attachment%3B%20filename%3DSkinsRestorer.jar&response-content-type=application%2Foctet-stream";
            hash = "sha256-D4pvASk15fgqDreBXAZl4+YEnys3exLRRrYXXm+0kqc=";
          };

          "plugins/ShopKeepers.jar" = pkgs.fetchurl rec {
            pname = "ShopKeepers";
            version = "2.23.0";
            url = "https://mediafilez.forgecdn.net/files/5619/313/Shopkeepers-${version}.jar";
            hash = "sha256-IFiPr4rFOH7t3IY663s8WBN5wWDQuG0rU1jL61wiWrA=";
          };

          "plugins/WorldEdit.jar" = pkgs.fetchurl rec {
            pname = "worldedit-bukkit";
            version = "7.3.7";
            url = "https://cdn.modrinth.com/data/1u6JkXh5/versions/H12HdUau/${pname}-${version}.jar";
            hash = "sha256-5W+VZBHAR314IPVqAz2Ghnw6nOGA69H1W8leraaZl1U=";
          };
          # symlink more config files if needed ....
        };
      };
    };
  };
  systemd.tmpfiles.rules = [ "d /srv/minecraft 0770 minecraft minecraft" ];

  users.groups.minecraft = { };
  users.users.minecraft = {
    isSystemUser = true;
    group = "minecraft";
    home = "/srv/minecraft";
  };
}

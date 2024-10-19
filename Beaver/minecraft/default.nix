{ pkgs, inputs, ... }:
{
  imports = [ inputs.nix-minecraft.nixosModules.minecraft-servers ];
  nixpkgs.overlays = [ inputs.nix-minecraft.overlay ];

  services.minecraft-servers = {
    enable = true;
    eula = true; # Automatically accept eula
    dataDir = "/srv/minecraft";
    runDir = "/srv/minecraft";
    servers = {
      fallen-kingdom = {
        enable = true;
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

        # whitelist = { /* */ };

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
  systemd.tmpfiles.rules = [
    "d /srv/minecraft 0770 minecraft minecraft"
  ];

  users.groups.minecraft = { };
  users.users.minecraft = {
    isSystemUser = true;
    group = "minecraft";
    home = "/srv/minecraft";
  };
}

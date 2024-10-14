{ pkgs, inputs, ... }:
{
  imports = [ inputs.nix-minecraft.nixosModules.minecraft-servers ];
  nixpkgs.overlays = [ inputs.nix-minecraft.overlay ];

  services.minecraft-servers.servers = {
    fallen-kingdom-server = {
      enable = true;
      eula = true; # Automatically accept eula
      autoStart = true; # Start on boot
      openFirewall = true; # Open port specified in the serverProperties config

      # Spin of the minecraft server to use and version (using unstable nixos branch to get latest papermc 1.21 version)
      package = pkgs.unstable.paperServers.papermc-1_21;

      # Directory where to put all the servers files
      dataDir = "/var/minecraft-fallen-kingdom";

      serverProperties = {
        # A list can be found here : https://minecraft.wiki/w/Server.properties
        motd = "Fallen Kingdom minecraft server powered by NixOS!";
        server-port = 25565;
        difficulty = 2;
        gamemode = 1;
        max-players = 10;
        white-list = false;
        enable-command-block = true;
        view-distance = 10;
        simulation-distance = 8;
        spawn-animals = true;
        spawn-monsters = true;
        spawn-npcs = true;
      };

      # Performance jvm flags
      jvmOpts = "-Xms2G -Xmx6G 
      -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 
      -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch 
      -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M 
      -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 
      -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 
      -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 
      -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true";

      # whitelist = { /* */ };

      # symlinks can be used to manage declaratively other files such as plugins, mods...
      symlinks = {
        plugins = pkgs.linkFarmFromDrvs "plugins"
          (builtins.attrValues {
            FallenKingdom = fetchurl { url = "https://cdn.modrinth.com/data/wKYpobLb/versions/8oEbkpgh/FallenKingdom-2.23.2.jar"; sha512 = "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"; };
            # other plugins ...
          });
      };

      # another-server = {
      #   enable = false;
      #   package = pkgs.fabricServers.fabric-1_18_2;
      #   dataDir = "/var/minecraft-server";
      #   serverProperties = { /* */ };
      #   whitelist = { /* */ };
      # };
    };
  };
}

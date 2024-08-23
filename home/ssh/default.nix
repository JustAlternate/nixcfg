_: {
  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";
    matchBlocks = {
      "swordfish" = {
        # justalternate.fr
        hostname = "49.13.235.192";
        user = "root";
        identityFile = "~/.ssh/id_ed25519";
        port = 22;
      };
      "beaver" = {
        # migrated justalternate.fr
        hostname = "195.201.116.51";
        user = "root";
        identityFile = "~/.ssh/id_ed25519";
        port = 22;
      };
      "ocelot" = {
        #batocera
        hostname = "192.168.1.242";
        user = "root";
        identityFile = "~/.ssh/id_ed25519";
        port = 22;
      };
      "github.com" = {
        user = "git";
        identityFile = "~/.ssh/id_ed25519";
        forwardAgent = true;
      };
    };
  };
}

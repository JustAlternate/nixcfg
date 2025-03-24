_: {
  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";
    matchBlocks = {
      "beaver" = {
        # justalternate.fr
        hostname = "195.201.116.51";
        user = "root";
        identityFile = "~/.ssh/id_ed25519";
      };
      "gh-explorer" = {
        # gh-explorer.fr
        hostname = "188.245.183.30";
        user = "root";
        identityFile = "~/.ssh/id_ed25519";
        port = 443;
      };
      "GeckoNixos1" = {
        # RPI3b+
        hostname = "192.168.1.248";
        user = "root";
        port = 22;
        identityFile = "~/.ssh/id_ed25519";
      };
      "GeckoNixos2" = {
        # RPI4B
        hostname = "192.168.1.247";
        user = "root";
        port = 22;
        identityFile = "~/.ssh/id_ed25519";
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

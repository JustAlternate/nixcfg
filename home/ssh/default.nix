{ ... }:
{
  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";
    matchBlocks = {
      "swordfish" = {
        hostname = "49.13.235.192";
        user = "root";
        identityFile = "~/.ssh/id_ed25519";
        port = 22;
      };
      "ocelot" = {
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

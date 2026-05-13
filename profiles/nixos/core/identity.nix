{ pkgs, lib, ... }:
{
  options.machineName = lib.mkOption {
    type = lib.types.str;
    default = "unknown";
    description = "The name of the machine (e.g., swordfish, owl, parrot, beaver)";
  };

  config = {
    users = {
      defaultUserShell = pkgs.zsh;
      users.justalternate = {
        home = "/home/justalternate";
        isNormalUser = true;
        description = "justalternate";
        extraGroups = [
          "networkmanager"
          "wheel"
          "input"
          "uinput"
        ];
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKSO4cOiA8s9hVyPtdhUXdshxDXXPU15qM8xE0Ixfc21"
        ];
      };
    };

    security = {
      sudo = {
        enable = true;
        extraConfig = ''
          justalternate ALL=(ALL) NOPASSWD: ALL
        '';
      };

      polkit.enable = true;
    };

    programs = {
      gnupg.agent = {
        enable = true;
        enableSSHSupport = false;
      };
      ssh.startAgent = true;
    };
  };
}

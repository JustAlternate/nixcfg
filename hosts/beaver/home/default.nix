{ ... }:
{
  imports = [
    ../../../home/shell
    ../../../modules/home/ssh.nix
    ../../../modules/home/git.nix
  ];

  home = {
    username = "root";
    homeDirectory = "/root";

    stateVersion = "24.05";

    sessionVariables = {
      EDITOR = "nvim";
    };
  };

  zsh.envVar.enable = false;

  programs.home-manager.enable = true;
}

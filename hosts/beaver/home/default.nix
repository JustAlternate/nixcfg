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

    # For env var
    sessionVariables = {
      EDITOR = "nvim";
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}

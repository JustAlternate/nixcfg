{ pkgs, ... }:
{
  imports = [
    ./zsh.nix
    ../../shared/nvim
    ../../shared/ssh.nix
    ../../shared/git.nix
    ./git.nix
    ./ssh.nix
  ];

  home = {
    stateVersion = "24.05";
    packages = with pkgs; [
      postgresql
      unstable.go
    ];

    # For env var
    sessionVariables = {
      EDITOR = "nvim";
    };
  };

  xdg.enable = true;
  programs.home-manager.enable = true;
}

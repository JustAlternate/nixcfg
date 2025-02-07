{ pkgs, ... }:
{
  imports = [
    ./zsh.nix
    ../../shared/ssh.nix
    ../../shared/git.nix
    ./git.nix
    ./ssh.nix
    ../../shared/desktop/dev/python
  ];

  home = {
    stateVersion = "24.05";
    packages = with pkgs; [
      postgresql
      unstable.go
      mysql80

      jdk17

      sbt-extras
      scala_2_13
      scalafmt
    ];

    # For env var
    sessionVariables = {
      EDITOR = "nvim";
    };
  };

  xdg.enable = true;
  programs.home-manager.enable = true;
}

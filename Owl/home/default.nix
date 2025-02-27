{ pkgs, ... }:
{
  imports = [
    ./zsh.nix
    ../../shared/ssh.nix
    ../../shared/git.nix
    ./git.nix
    ./ssh.nix
    ../../shared/desktop/dev/python
    ../../shared/desktop/kitty.nix
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

      graphqurl
    ];

    # For env var
    sessionVariables = {
      EDITOR = "nvim";
    };
  };

  xdg.enable = true;
  programs.home-manager.enable = true;
  programs.kitty = {
    settings = {
      hide_window_decorations = "titlebar-only";
    };
  };
}

{ pkgs, ... }:
{
  imports = [
    ../../shared/zsh.nix
    ../../shared/ssh.nix
    ../../shared/git.nix
    ../../shared/ssh.nix
    ../../shared/desktop/dev/python
    ../../shared/desktop/kitty.nix
  ];

  options.git.work.enable = true;
  options.ssh.work.enable = true;

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

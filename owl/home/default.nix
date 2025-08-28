{
  pkgs,
  ...
}:
{
  imports = [
    ../../shared/desktop/dev/database
    ../../shared/shell/zsh.nix
    ../../shared/ssh.nix
    ../../shared/git.nix
    ../../shared/fastfetch.nix
    ../../shared/desktop/dev/python
  ];

  git.work.enable = true;
  ssh.work.enable = true;

  home = {
    packages = with pkgs; [
      postgresql
      go
      htop
      btop
      grpcurl
      golangci-lint
      unstable.codex
      goreleaser

      mysql80

      jdk17

      sbt-extras
      scala_2_13
      scalafmt

      graphqurl
      opentofu

      devenv
    ];

    # For env var
    sessionVariables = {
      EDITOR = "nvim";
    };

    sessionPath = [
      "/opt/homebrew/bin"
      "/opt/homebrew/sbin"
      "/opt/homebrew/opt/php@7.4/bin"
      "/opt/homebrew/opt/openjdk/bin"
      "$HOME/go/bin"
    ];

    stateVersion = "24.05";
  };

  xdg.enable = true;
}

{
  pkgs,
  ...
}:
{
  imports = [
    ../../../modules/home/ssh.nix
    ../../../modules/home/git.nix
    ../../../modules/home/tmux.nix
    ../../../modules/home/zsh.nix
    ../../../home/desktop/ghostty.nix
    ../../../home/dev/database.nix
    ../../../home/shell/fastfetch.nix
    ../../../home/shell/k9s.nix
  ];

  ssh.work.enable = true;
  git.work.enable = true;
  zsh.work.enable = true;

  home = {
    packages = with pkgs; [
      postgresql
      unstable.go
      btop
      grpcurl
      unstable.golangci-lint
      goreleaser
      unstable.docker
      docker-compose

      posting

      mysql84

      graphqurl

      bemoji
      yazi
      marp-cli
      zip
      sshpass
      zoxide
      eza
      fzf
      lazygit

      # Development
      openssh
      git
      gcc
      lua
      cmake
      gnumake
      uv
      awscli2
      devenv
      bat
      gh
      circleci-cli
      opentofu
      unstable.nomad
      statix # Lints and suggestions for the nix programming language
      deadnix # Find and remove unused code in .nix source files
      nixfmt # Nix Code Formatter
      kubectl
      eksctl
      kubernetes-helm
      # Monitoring
      htop
      # Cli tools, Utility -- mac safe subset
      ripgrep
      unstable.rtk
      gh-dash
      asciinema
      asciinema-agg
      unzip
      jq
      sshfs
      sops
      # Text editors
      vim
      unstable.opencode

      pandoc
      texliveFull
    ];

    # For env var
    sessionVariables = {
      EDITOR = "nvim";
      JABBA_VERSION = "0.11.2";
    };

    sessionPath = [
      "/opt/homebrew/bin/"
      "/opt/homebrew/opt/php@7.4/bin"
      "$HOME/go/bin"
      "$HOME/Library/Application Support/Coursier/bin"
      "$HOME/.jabba/bin"
      "$HOME/.jabba/jdk/openjdk@17.0.2/Contents/Home/bin/"
    ];

    stateVersion = "24.05";
  };

  xdg.enable = true;

}

{
  pkgs,
  config,
  ...
}:
{
  imports = [
    ../../shared/desktop/ghostty.nix
    ../../shared/desktop/dev/database
    ../../shared/ssh.nix
    ../../shared/git.nix
    ../../shared/fastfetch.nix
    # ../../shared/desktop/dev/python
  ];

  git.work.enable = true;
  ssh.work.enable = true;

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    dotDir = ".config/zsh";
    shellAliases = {
      lg = "lazygit";
      ll = "ls -la";
      nixcfg = "cd ~/nixcfg";
      ls = "eza --color=auto --icons=always";
      cd = "z";
      nvimf = "nvim $(fzf)";

      db_connect = "${config.home.homeDirectory}/github/system-toolbox/databases/connect.sh";
      tdm_secret = "vault read postgresql/creds/shared-main-system-postgresql-db-dev-technical-debt -format=json | jq .data";
    };
    history = {
      size = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
    };
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "vi-mode"
      ];
      theme = "edvardm";
    };
    initContent = ''
      # Skip if file doesn't exist
      [ -f "${config.home.homeDirectory}/.cache/wal/sequences" ] &&
        cat "${config.home.homeDirectory}/.cache/wal/sequences"
      while IFS='=' read -r name value; do
        [[ $name != \#* ]] && export "$name=$value"
      done < ~/env-var/.env
      # Initialize zoxide (fast)
      eval "$(zoxide init zsh)"
      # Keybindings (minimal)
      bindkey '^J' history-incremental-search-backward
      bindkey '^K' history-incremental-search-forward
      bindkey '^O' autosuggest-accept
    '';
  };

  home = {
    packages = with pkgs; [
      postgresql
      go
      btop
      grpcurl
      unstable.golangci-lint
      goreleaser
      docker
      docker-compose

      posting

      mysql80

      jdk17

      sbt-extras
      scala_2_13
      scalafmt

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
      go
      cmake
      gnumake
      awscli2
      devenv
      pre-commit
      gh
      statix # Lints and suggestions for the nix programming language
      deadnix # Find and remove unused code in .nix source files
      nixfmt-rfc-style # Nix Code Formatter
      kubectl
      eksctl
      k9s
      # Monitoring
      htop
      # Cli tools, Utility -- mac safe subset
      unzip
      jq
      sshfs
      sops
      # Text editors
      vim
      master.opencode
    ];

    # For env var
    # sessionVariables = {
    #   EDITOR = "nvim";
    # };
    #
    # sessionPath = [
    #   "/opt/homebrew/opt/php@7.4/bin"
    #   "/opt/homebrew/opt/openjdk/bin"
    #   "$HOME/go/bin"
    # ];

    stateVersion = "24.05";
  };

  xdg.enable = true;

}

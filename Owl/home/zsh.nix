{ pkgs, config, ... }:
{
  home = {
    packages = with pkgs; [
      fastfetch
      zsh
      zoxide
      eza
      lazygit
    ];
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      ll = "ls -l";
      ls = "eza --color=auto --icons=always";
      cd = "z";
      neofetch = "fastfetch";
      lg = "lazygit";
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
      theme = "agnoster";
    };

    initExtra = ''
      source ~/env-var/.env
      fastfetch
      eval "$(zoxide init zsh)"

      bindkey '^J' history-incremental-search-backward
      bindkey '^K' history-incremental-search-forward
      bindkey -r '^R'
      bindkey -r '^S'

      # Bind Ctrl+O to accept the entire suggestion
      bindkey '^O' autosuggest-accept

    '';

    sessionVariables = {
      PATH = "/opt/homebrew/opt/openjdk/bin:/opt/homebrew/Cellar/python@3.11/bin:/Users/loicweber/go/bin:/opt/homebrew/bin:$PATH";
      GOPATH = "/Users/loicweber/go";
      GOBIN = "/Users/loicweber/go/bin";
    };
  };
}

{ pkgs, config, ... }:
{
  home = {
    packages = with pkgs; [
      zsh
      zoxide
      eza
      lazygit
      tgpt
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
      db_connect = "~/github/system-toolbox/databases/./connect.sh";
      ai = "tgpt --provider openai --url https://api.deepinfra.com/v1/openai/chat/completions --model Qwen/Qwen2.5-Coder-32B-Instruct";
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
      # Add path of homebrew installed app to my zshrc managed by nix
      PATH = "/opt/homebrew/opt/php@7.4/bin:/opt/homebrew/opt/php@7.4/bin:/opt/homebrew/opt/openjdk/bin:/opt/homebrew/Cellar/python@3.11/bin:/Users/loicweber/go/bin:/opt/homebrew/bin:$PATH";
      GOPATH = "/Users/loicweber/go";
      GOBIN = "/Users/loicweber/go/bin";
    };
  };
}

{ pkgs, config, ... }:
{
  home.packages = with pkgs; [
    zoxide
    tgpt
    eza
  ];
  # Programs configuration
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      lg = "lazygit";
      ll = "ls -l";
      nixcfg = "cd ~/nixcfg";
      ls = "eza --color=auto --icons=always";
      cd = "z";
      neofetch = "fastfetch";
      ssh = "kitten ssh";
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
        "dotenv"
        "vi-mode"
      ];
      theme = "agnoster";
    };

    initExtra = ''
      fastfetch
      eval "$(zoxide init zsh)"
      source ~/env-var/.env

      bindkey '^J' history-incremental-search-backward
      bindkey '^K' history-incremental-search-forward
      bindkey -r '^R'
      bindkey -r '^S'

      bindkey '^O' autosuggest-accept
    '';

    initExtraFirst = ''
      cat ${config.home.homeDirectory}/.cache/wal/sequences
    '';
  };
}

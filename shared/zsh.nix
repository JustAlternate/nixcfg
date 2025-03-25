{ pkgs, config, ... }:
{
  options.desktop = {
    enable = pkgs.lib.mkOption {
      type = pkgs.lib.types.bool;
      default = false;
    };
  };

  options.mac = {
    enable = pkgs.lib.mkOption {
      type = pkgs.lib.types.bool;
      default = false;
    };
  };

  config = pkgs.lib.mkIf config.desktop.enable {
    programs.zsh = {
      initExtraFirst = ''
        cat ${config.home.homeDirectory}/.cache/wal/sequences
      '';
      initExtra = ''
        source ~/env-var/.env
      '';
    };
  };

  config = pkgs.lib.mkIf config.mac.enable {
    programs.zsh = {
      initExtra = ''
        source ~/env-var/.env
      '';
      shellAliases = {
        db_connect = "~/github/system-toolbox/databases/./connect.sh";
      };
      sessionVariables = {
        # Add path of homebrew installed app to my zshrc managed by nix
        PATH = "/opt/homebrew/opt/php@7.4/bin:/opt/homebrew/opt/php@7.4/bin:/opt/homebrew/opt/openjdk/bin:/opt/homebrew/Cellar/python@3.11/bin:/Users/loicweber/go/bin:/opt/homebrew/bin:$PATH";
        GOPATH = "/Users/loicweber/go";
        GOBIN = "/Users/loicweber/go/bin";
      };
    };
  };

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

      bindkey '^J' history-incremental-search-backward
      bindkey '^K' history-incremental-search-forward
      bindkey -r '^R'
      bindkey -r '^S'

      bindkey '^O' autosuggest-accept
    '';
  };
}

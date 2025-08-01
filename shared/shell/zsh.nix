{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
{
  options.desktop.enable = mkEnableOption "desktop";

  config = mkMerge [
    (mkIf config.desktop.enable {
      programs.zsh = {
        initContent = ''
          [ -f "${config.home.homeDirectory}/.cache/wal/sequences" ] &&
            cat "${config.home.homeDirectory}/.cache/wal/sequences"
        '';
      };
    })

    (mkIf pkgs.stdenv.isDarwin {
      programs.zsh = {
        shellAliases = {
          db_connect = "${config.home.homeDirectory}/github/system-toolbox/databases/connect.sh";
          tdm_secret = "vault read postgresql/creds/shared-main-system-postgresql-db-dev-technical-debt -format=json | jq .data";
        };
      };
    })

    {
      home.packages = with pkgs; [
        zoxide
        tgpt
        eza
        lazygit
      ];

      programs.direnv = {
        enable = true;
      };

      xdg.configFile."direnv/direnv.toml".source = ./direnv.toml;

      programs.zsh = {
        enable = true;
        enableCompletion = true;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;
        shellAliases = {
          lg = "lazygit";
          ll = "ls -la";
          nixcfg = "cd ~/nixcfg";
          ls = "eza --color=auto --icons=always";
          cd = "z";
          neofetch = "fastfetch";
          ssh = "kitten ssh";
          ai = "tgpt --provider openai --url https://openrouter.ai/api/v1/chat/completions --model qwen/qwen3-30b-a3b-instruct-2507 --preprompt 'The user is using Linux, if the question is about a linux command or a line of code, please answer with only one or 2 examples and do not give explanation unless the user asked for it. If the question is not specificly about a command or a line of code explain but make sure to be straight to the point. /nothink'";
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
          while IFS='=' read -r name value; do
            [[ $name != \#* ]] && export "$name=$value"
          done < ~/env-var/.env
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
  ];
}

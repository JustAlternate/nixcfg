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

          while IFS='=' read -r name value; do
            [[ $name != \#* ]] && export "$name=$value"
          done < ~/env-var/.env
        '';
      };
    })

    (mkIf pkgs.stdenv.isDarwin {
      programs.zsh = {
        initContent = ''
          while IFS='=' read -r name value; do
            [[ $name != \#* ]] && export "$name=$value"
          done < ~/env-var/.env
        '';
        shellAliases = {
          db_connect = "${config.home.homeDirectory}/github/system-toolbox/databases/connect.sh";
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
          ai = "tgpt --provider openai --url https://api.deepinfra.com/v1/openai/chat/completions --model Qwen/Qwen2.5-Coder-32B-Instruct --preprompt 'The user is using Linux please answer promptly with examples but dont give explanation unless the user asked for it'";
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
          theme = "edvardm";
        };
        initContent = ''
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

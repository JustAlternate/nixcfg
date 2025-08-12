{
  pkgs,
  config,
  lib,
  ...
}:
let
  llm-mlx = import ./llm-mlx.nix;
in
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
        llm
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

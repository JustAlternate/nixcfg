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
    (mkIf pkgs.stdenv.isDarwin {
      programs.zsh = {
        shellAliases = {
          db_connect = "${config.home.homeDirectory}/github/system-toolbox/databases/connect.sh";
          tdm_secret = "vault read postgresql/creds/shared-main-system-postgresql-db-dev-technical-debt -format=json | jq .data";
        };
      };
    })

    {
      programs.direnv = {
        enable = true;
      };

      xdg.configFile."direnv/direnv.toml".source = ./direnv.toml;

      programs.zsh = {
        enable = true;
        enableCompletion = true;
        autosuggestion.enable = true;
        shellAliases = {
          lg = "lazygit";
          ll = "ls -la";
          nixcfg = "cd ~/nixcfg";
          ls = "eza --color=auto --icons=always";
          cd = "z";
          neofetch = "fastfetch";
          ssh = "kitten ssh";
          nvimf = "nvim $(fzf)";
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

          # Load env vars only when needed (lazy-loading)
          function load_env() {
            while IFS='=' read -r name value; do
              [[ $name != \#* ]] && export "$name=$value"
            done < ~/env-var/.env
          }

          # Initialize zoxide (fast)
          eval "$(zoxide init zsh)"

          # Keybindings (minimal)
          bindkey '^J' history-incremental-search-backward
          bindkey '^K' history-incremental-search-forward
          bindkey '^O' autosuggest-accept
        '';
      };
    }
  ];
}

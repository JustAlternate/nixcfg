{
  config,
  lib,
  machineName ? "unknown",
  ...
}:
with lib;
let
  cfg = config.zsh;
in
{
  options.zsh = {
    work.enable = mkEnableOption "work shell profile (kubectl prompt, work aliases)";
    hyprlandAutostart.enable = mkEnableOption "auto-start Hyprland on tty1 login";
  };

  config = {
    home.file.".config/zsh/themes/edvardm-custom.zsh-theme".source = ./edvardm-custom.zsh-theme;

    programs.zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      dotDir = "${config.xdg.configHome}/zsh";
      shellAliases = mkMerge [
        {
          lg = "lazygit";
          ll = "ls -la";
          nixcfg = "cd ~/nixcfg";
          ls = "eza --color=auto --icons=always";
          cd = "z";
          nvimf = "nvim $(fzf)";
        }
        (mkIf (!cfg.work.enable) {
          cat = "bat --paging=never";
        })
        (mkIf cfg.work.enable {
          db_connect = "${config.home.homeDirectory}/github/system-toolbox/databases/connect.sh";
          tdm_secret = "vault read postgresql/creds/shared-main-system-postgresql-db-dev-technical-debt -format=json | jq .data";
          k9s-prod = "aws sts get-caller-identity --profile prod >/dev/null 2>&1 || aws sso login --profile prod || exit 1; kubectl config use-context prod && k9s";
          k9s-dev = "aws sts get-caller-identity --profile dev >/dev/null 2>&1 || aws sso login --profile dev || exit 1; kubectl config use-context dev && k9s";
          lfk-dev = "aws sts get-caller-identity --profile dev >/dev/null 2>&1 || aws sso login --profile dev || exit 1; kubectl config use-context dev && lfk";
          lfk-prod = "aws sts get-caller-identity --profile prod >/dev/null 2>&1 || aws sso login --profile prod || exit 1; kubectl config use-context prod && lfk";
        })
      ];
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
      };
      initContent = ''
        ${optionalString cfg.work.enable ''
          DISABLE_AUTO_UPDATE="true"
          DISABLE_MAGIC_FUNCTIONS="true"
          DISABLE_COMPFIX="true"
        ''}
        # kubectl completion
        command -v kubectl >/dev/null && source <(kubectl completion zsh)

        # pywal colorscheme
        [ -f "${config.home.homeDirectory}/.cache/wal/sequences" ] &&
          cat "${config.home.homeDirectory}/.cache/wal/sequences"

        # env vars
        if [ -f ~/env-var/.env ]; then
          while IFS='=' read -r name value; do
            [[ $name != \#* ]] && export "$name=$value"
          done < ~/env-var/.env
        fi

        # zoxide
        command -v zoxide >/dev/null && eval "$(zoxide init zsh)"

        # Keybindings (minimal)
        bindkey '^J' history-incremental-search-backward
        bindkey '^K' history-incremental-search-forward
        bindkey '^O' autosuggest-accept

        # Load custom theme with single spaces
        source "${config.home.homeDirectory}/.config/zsh/themes/edvardm-custom.zsh-theme"
        # Add machine name to prompt
        PROMPT="%{$fg[green]%}[${machineName}]%{$reset_color%} $PROMPT"
        ${optionalString cfg.work.enable ''
          # Right prompt: k8s context with dev=blue prod=red
          _rps1_info() {
            local k8s_ctx k8s_color
            k8s_ctx="$(kubectl config current-context 2>/dev/null || echo none)"
            if [[ "$k8s_ctx" == *dev* ]]; then k8s_color=blue
            elif [[ "$k8s_ctx" == *prod* ]]; then k8s_color=red
            else k8s_color=cyan; fi
            echo "%F{$k8s_color}k8s:$k8s_ctx%f"
          }
          RPS1='$(_rps1_info)'
        ''}
        ${optionalString cfg.hyprlandAutostart.enable ''
          # Auto-start Hyprland on TTY login
          if [ -z "$WAYLAND_DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ] && command -v start-hyprland >/dev/null; then
            exec start-hyprland
          fi
        ''}
      '';
    };
  };
}

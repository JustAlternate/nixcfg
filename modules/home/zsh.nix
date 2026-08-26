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
    envVar.enable = mkEnableOption "legacy ~/env-var/.env loading" // {
      default = true;
    };
    tmuxAutoStart.enable = mkEnableOption "auto-start tmux on shell login" // {
      default = true;
    };
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
        # Home Manager PATH setup runs after initContent; ensure nix profile
        # packages (tmux, etc.) are findable early.
        export PATH="$HOME/.nix-profile/bin:$PATH"

        ${optionalString cfg.hyprlandAutostart.enable ''
          # Auto-start Hyprland on TTY login — MUST run before the tmux autostart:
          # if tmux execs first, tty becomes /dev/pts/N and the /dev/tty1 check
          # below could never pass, so Hyprland would never launch.
          if [ -z "$WAYLAND_DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ] && command -v start-hyprland >/dev/null; then
            exec start-hyprland
          fi
        ''}

        ${optionalString cfg.tmuxAutoStart.enable ''
          # Auto-start tmux: attach to session "main" if it exists, otherwise create it.
          # Skipped on the Linux VT (where Hyprland owns login) — only fire inside a
          # real terminal emulator once a Wayland session is up.
          if command -v tmux >/dev/null && [ -z "$TMUX" ] && [ -n "$WAYLAND_DISPLAY" ]; then
            exec tmux new-session -A -s main
          fi
        ''}

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

        ${optionalString cfg.envVar.enable ''
          # env vars (non-sensitive tool config)
          if [ -f ~/env-var/.env ]; then
            while IFS='=' read -r name value; do
              [[ $name != \#* ]] && export "$name=$value"
            done < ~/env-var/.env
          fi
        ''}
        # API keys (sops-managed) — check -r to avoid "permission denied" when file is root-only (see 03130c9)
        [ -r /run/secrets/llm-env ] && source /run/secrets/llm-env
        [ -r ~/.config/secrets/llm.env ] && set -a && source ~/.config/secrets/llm.env && set +a
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
          # Write k8s context to cache for tmux status bar (RPS1 handled there now)
          _k8s_cache() {
            kubectl config current-context 2>/dev/null > "/tmp/tmux-kube-context-$UID"
          }
          precmd_functions+=_k8s_cache
        ''}
      '';
    };
  };
}

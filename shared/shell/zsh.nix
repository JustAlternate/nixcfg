{
  pkgs,
  config,
  lib,
  machineName ? "unknown",
  ...
}:
with lib;
{
  # Copy custom theme file
  home.file.".config/zsh/themes/edvardm-custom.zsh-theme".source = ./edvardm-custom.zsh-theme;

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    dotDir = ".config/zsh";
    shellAliases = {
      lg = "lazygit";
      ll = "ls -la";
      nixcfg = "cd ~/nixcfg";
      ls = "eza --color=auto --icons=always";
      cd = "z";
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
    };
    initContent = ''
      			source <(kubectl completion zsh)
              # Skip if file doesn't exist
              [ -f "${config.home.homeDirectory}/.cache/wal/sequences" ] &&
                cat "${config.home.homeDirectory}/.cache/wal/sequences"
              while IFS='=' read -r name value; do
                [[ $name != \#* ]] && export "$name=$value"
              done < ~/env-var/.env
              # Initialize zoxide (fast)
              eval "$(zoxide init zsh)"
              # Keybindings (minimal)
              bindkey '^J' history-incremental-search-backward
              bindkey '^K' history-incremental-search-forward
              bindkey '^O' autosuggest-accept
              # Load custom theme with single spaces
              source "${config.home.homeDirectory}/.config/zsh/themes/edvardm-custom.zsh-theme"
              # Add machine name to prompt
              PROMPT="%{$fg[green]%}[${machineName}]%{$reset_color%} $PROMPT"
              # Auto-start Hyprland on TTY login
              if [ -z "$WAYLAND_DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
                exec Hyprland
              fi
    '';
  };
}

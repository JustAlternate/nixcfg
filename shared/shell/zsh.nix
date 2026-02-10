{
  pkgs,
  config,
  lib,
  machineName ? "unknown",
  ...
}:
with lib;
{
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
      theme = "edvardm";
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
            # Add machine name to prompt
            MACHINE_NAME="${machineName}"
            # Remove leading space from original prompt to avoid double spacing
            PROMPT="%{$fg[green]%}[$MACHINE_NAME]%{$reset_color%} ''${PROMPT# }"
    '';
  };
}

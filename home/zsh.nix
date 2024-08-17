{ pkgs
, config
, ...
}: {
  home.packages = with pkgs; [
    zoxide
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
      nixcfg = "cd ~/.config/dotfiles";
      ls = "eza --color=auto --icons=always";
      cd = "z";
      neofetch = "fastfetch";
    };

    history = {
      size = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
    };

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "dotenv" "vi-mode" ];
      theme = "agnoster";
    };

    initExtra = ''
      fastfetch
      eval "$(zoxide init zsh)"
    '';

    initExtraFirst = ''
      cat /home/justalternate/.cache/wal/sequences
    '';
  };
}

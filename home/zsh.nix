{ pkgs, config, ... }:
{
  home.packages = with pkgs; [
    zsh
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
      ll = "ls -l";
      nixcfg = "cd ~/.config/dotfiles";
      ls = "eza --color=auto --icons=always";
      cd = "z";
      neofetch = "fastfetch -c examples/8";
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
      fastfetch -c examples/8
      eval "$(zoxide init zsh)"
    '';

    initExtraFirst = ''
      cat /home/justalternate/.cache/wal/sequences
    '';
  };
}

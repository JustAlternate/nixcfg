{ pkgs, config, ... }: {
  home = {
    packages = with pkgs; [
      fastfetch
      zsh
      zoxide
      eza
    ];
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      ll = "ls -l";
      ls = "eza --color=auto --icons=always";
      cd = "z";
      neofetch = "fastfetch";
      lg = "lazygit";
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

    sessionVariables = {
      PATH = "/opt/homebrew/opt/openjdk/bin:/opt/homebrew/Cellar/python@3.11/bin:/usr/local/go/bin:/opt/homebrew/bin:$PATH";
      GOPATH = "/usr/local/go";
      GOBIN = "/usr/go/bin";


      # Usage of swissknife :
      ARTIFACTORY_USERNAME = "justalternateidz";
      # ARTIFACTORY_PASSWORD = "${config.sops.secrets.test-pass}"; #NOT WORKING
      NOMAD_ADDR = "https://nomad.dev.iadvize.io";
      GITHUB_USERNAME = "justalternateidz";
      CORE_MYSQL_USER = "livechat";

    };
  };
}

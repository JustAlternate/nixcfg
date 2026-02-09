_: {
  programs.ghostty = {
    enable = true;
    settings = {
      clipboard-read = "allow";
      clipboard-write = "allow";
      macos-non-native-fullscreen = true;
      desktop-notifications = false;
      app-notifications = "no-clipboard-copy";
      font-family = "Hack Nerd Font";
      font-size = 20;
    };
    enableZshIntegration = true;
    clearDefaultKeybinds = false;
  };
  programs.tmux = {
    enable = true;
    shell = "\${pkgs.zsh}/bin/zsh";
  };

}

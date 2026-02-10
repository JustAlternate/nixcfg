{ pkgs, ... }:
{
  programs.ghostty = {
    enable = true;
    # package = null;
    package = pkgs.unstable.ghostty;
    settings = {
      clipboard-read = "allow";
      clipboard-write = "allow";
      macos-non-native-fullscreen = true;
      desktop-notifications = false;
      app-notifications = "no-clipboard-copy";

      font-family = "Hack Nerd Font Mono";
      macos-titlebar-proxy-icon = "hidden";
      title = "Terminal";
      font-size = 25;
      quit-after-last-window-closed = true;
      quick-terminal-screen = "mouse";
      quick-terminal-autohide = true;
      window-decoration = "none";
      theme = "Catppuccin Frappe";
      keybind = "super+a=unbind";
    };
    enableZshIntegration = true;
    clearDefaultKeybinds = false;
  };
  programs.tmux = {
    enable = true;
    shell = "\${pkgs.zsh}/bin/zsh";
  };
}

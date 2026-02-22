{ pkgs, ... }:
{
  programs.ghostty = {
    enable = true;
    package = if pkgs.stdenv.isDarwin then null else pkgs.ghostty;
    settings = {
      clipboard-read = "allow";
      clipboard-write = "allow";
      macos-non-native-fullscreen = true;
      desktop-notifications = false;
      app-notifications = "no-clipboard-copy";
      font-family = "Hack Nerd Font";
      macos-titlebar-proxy-icon = "hidden";
      title = "Terminal";
      font-size = 18;
      quit-after-last-window-closed = true;
      confirm-close-surface = false;
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

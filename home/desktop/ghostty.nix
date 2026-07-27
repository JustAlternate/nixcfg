{ pkgs, ... }:
{
  programs.ghostty = {
    enable = true;
    package = if pkgs.stdenv.isDarwin then null else pkgs.ghostty;
    settings = {
      clipboard-read = "allow";
      clipboard-write = "allow";
      macos-non-native-fullscreen = true;
      macos-option-as-alt = "right";
      window-save-state = "never";
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
      keybind = [
        # Disable native splits and tabs — tmux owns layout
        "super+d=unbind"
        "super+shift+d=unbind"
        "super+t=unbind"
        "super+a=unbind"
        "ctrl+shift++=increase_font_size:1"
        "ctrl+shift+-=decrease_font_size:1"

        # Option+N → tmux jump-to-window (M-1..M-9, AZERTY-safe via physical key)
        "alt+physical:one=esc:1"
        "alt+physical:two=esc:2"
        "alt+physical:three=esc:3"
        "alt+physical:four=esc:4"
        "alt+physical:five=esc:5"
        "alt+physical:six=esc:6"
        "alt+physical:seven=esc:7"
        "alt+physical:eight=esc:8"
        "alt+physical:nine=esc:9"
      ];
    };
    enableZshIntegration = true;
    clearDefaultKeybinds = false;
  };
}

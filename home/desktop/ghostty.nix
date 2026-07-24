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
        "super+a=unbind"
        "ctrl+shift++=increase_font_size:1"
        "ctrl+shift+-=decrease_font_size:1"
        # AZERTY: digits need Shift, so alt+1 sends M-& not M-1.
        # Use physical key codes (W3C digit_N) to match the key position
        # regardless of layout. Works with left Alt on all platforms,
        # and with right Option on macOS via macos-option-as-alt=right.
        "alt+digit_1=esc:1"
        "alt+digit_2=esc:2"
        "alt+digit_3=esc:3"
        "alt+digit_4=esc:4"
        "alt+digit_5=esc:5"
        "alt+digit_6=esc:6"
        "alt+digit_7=esc:7"
        "alt+digit_8=esc:8"
        "alt+digit_9=esc:9"
      ];
    };
    enableZshIntegration = true;
    clearDefaultKeybinds = false;
  };
}

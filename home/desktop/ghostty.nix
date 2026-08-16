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

        # Ctrl/Super + top-row → tmux jump-to-window (M-1..M-9, AZERTY-safe via physical key).
        # Alt is unusable here: Hyprland mainMod is ALT_R and right-Alt is AltGr on fr layout.
        "super+physical:one=esc:1"
        "super+physical:two=esc:2"
        "super+physical:three=esc:3"
        "super+physical:four=esc:4"
        "super+physical:five=esc:5"
        "super+physical:six=esc:6"
        "super+physical:seven=esc:7"
        "super+physical:eight=esc:8"
        "super+physical:nine=esc:9"
        "ctrl+physical:one=esc:1"
        "ctrl+physical:two=esc:2"
        "ctrl+physical:three=esc:3"
        "ctrl+physical:four=esc:4"
        "ctrl+physical:five=esc:5"
        "ctrl+physical:six=esc:6"
        "ctrl+physical:seven=esc:7"
        "ctrl+physical:eight=esc:8"
        "ctrl+physical:nine=esc:9"
      ];
    };
    enableZshIntegration = true;
    clearDefaultKeybinds = false;
  };
}

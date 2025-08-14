{ pkgs, ... }:
{

  #TODO: implements aerospace-scratchpad
  # environment.systemPackages = with pkgs; [
  #   # Requires custom packages
  #   copkgs.aerospace-scratchpad
  # ];

  services.jankyborders = {
    enable = true;
    width = 3.0;
    active_color = "#FF0000"; # Red border for focused windows
    inactive_color = "#CCCCCC"; # Gray border for unfocused windows
  };

  services.aerospace = {
    enable = true;
    package = pkgs.aerospace;

    settings = {
      "after-login-command" = [ ];
      "after-startup-command" = [ ];
      "start-at-login" = false;

      # Normalization options
      enable-normalization-flatten-containers = true;
      enable-normalization-opposite-orientation-for-nested-containers = true;

      # Layout options
      "accordion-padding" = 30;
      "default-root-container-layout" = "tiles"; # tiles | accordion
      "default-root-container-orientation" = "auto"; # horizontal | vertical | auto

      # Focus changes on monitor switch
      "on-focused-monitor-changed" = [ "move-mouse monitor-lazy-center" ];

      "workspace-to-monitor-force-assignment" = {
        "1" = "secondary";
        "2" = "secondary";
        "3" = "main";
        "4" = "secondary";
        "5" = "main";
        "6" = "secondary";
        "7" = "secondary";
        "8" = "secondary";
        "9" = "secondary";
        "10" = "main";
      };

      # macOS hide application behavior
      automatically-unhide-macos-hidden-apps = false;

      # Key mapping preset
      key-mapping = {
        preset = "qwerty";
      };

      # Gaps configuration: inner (between windows) and outer (between monitor edge and windows)
      gaps = {
        inner = {
          horizontal = 0;
          vertical = 0;
        };
        outer = {
          left = 5;
          bottom = 5;
          top = 5;
          right = 5;
        };
      };

      on-window-detected = [
        {
          "if".app-name-regex-substring = "Finder";
          run = "layout floating";
        }
        {
          "if".app-name-regex-substring = "Settings";
          run = "layout floating";
        }
      ];

      mode = {
        main = {
          binding = {
            "cmd-t" = "exec-and-forget open -n /Applications/Ghostty.app/";

            # Layout commands
            # "cmd-period" = "layout tiles horizontal vertical";
            # "cmd-comma" = "layout accordion horizontal vertical";

            # Focus commands
            "cmd-h" = "focus left";
            "cmd-j" = "focus down";
            "cmd-k" = "focus up";
            "cmd-l" = "focus right";

            # Move commands
            "cmd-shift-h" = "move left";
            "cmd-shift-j" = "move down";
            "cmd-shift-k" = "move up";
            "cmd-shift-l" = "move right";

            # Resize commands
            "cmd-shift-w" = "mode resize";

            # Workspace switching
            "cmd-1" = "workspace 1";
            "cmd-2" = "workspace 2";
            "cmd-3" = "workspace 3";
            "cmd-4" = "workspace 4";
            "cmd-5" = "workspace 5";
            "cmd-6" = "workspace 6";
            "cmd-7" = "workspace 7";
            "cmd-8" = "workspace 8";
            "cmd-9" = "workspace 9";
            "cmd-0" = "workspace 10";

            # Move window to workspace commands
            "cmd-shift-1" = "move-node-to-workspace 1";
            "cmd-shift-2" = "move-node-to-workspace 2";
            "cmd-shift-3" = "move-node-to-workspace 3";
            "cmd-shift-4" = "move-node-to-workspace 4";
            "cmd-shift-5" = "move-node-to-workspace 5";
            "cmd-shift-6" = "move-node-to-workspace 6";
            "cmd-shift-7" = "move-node-to-workspace 7";
            "cmd-shift-8" = "move-node-to-workspace 8";
            "cmd-shift-9" = "move-node-to-workspace 9";
            "cmd-shift-0" = "move-node-to-workspace 10";

            # Workspace back and forth and moving workspace between monitors
            "cmd-tab" = "workspace-back-and-forth";
            "cmd-shift-tab" = "move-workspace-to-monitor --wrap-around next";
          };
        };
        resize = {
          binding = {
            "cmd-shift-w" = "mode main";
            "h" = "resize width -50";
            "l" = "resize width +50";
            "j" = "resize height -50";
            "k" = "resize height +50";
          };
        };
      };
    };
  };
}

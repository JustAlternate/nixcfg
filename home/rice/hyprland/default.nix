{ pkgs, ... }: {
  home.packages = with pkgs; [
    pyprland
    hyprcursor
    hyprland-protocols
  ];
  xdg.configFile."hypr/pyprland.json".source = ./pyprland.json;

  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    WLR_NO_HARDWARE_CURSORS = "1";
  };

  wayland.windowManager.hyprland = {
    enable = true;
    package = pkgs.hyprland;
    xwayland.enable = true;

    extraConfig = ''
      # Electron env for wayland
      env = ELECTRON_OZONE_PLATFORM_HINT,auto
      #env = WLR_DRM_DEVICES,/dev/dri/card0:/dev/dri/card1

      # Monitor settings
      monitor=eDP-1, 1920x1080, 0x1080, 1
      monitor=HDMI-A-1, 1920x1080, 0x0, 1

      # Default env vars
      env = XCURSOR_SIZE,10

      # Input settings
      input {
        kb_layout = fr
        kb_variant =
        follow_mouse = 1

        touchpad {
          natural_scroll = no
        }

        sensitivity = 0
      }

      # Source colors
      source = ~/.cache/wal/colors-hypr

      general {
        gaps_in = 20
        gaps_out = 20
        border_size = 5
        col.active_border = $color1 $color5 100deg
        col.inactive_border = $color0
        layout = dwindle
      }

      misc {
        disable_hyprland_logo = true
        disable_splash_rendering = true
      }

      decoration {
        active_opacity = 1.0;
        inactive_opacity = 0.88;

        rounding = 10
        blur {
          enabled = true
          size = 2
          passes = 1
        }
        drop_shadow = yes
        shadow_range = 6
        shadow_render_power = 3
        col.shadow = rgba(1a1a1aee)
      }

      animations {
        enabled = yes
        bezier = wind, 0.05, 0.9, 0.1, 1.05
        bezier = winIn, 0.1, 1.1, 0.1, 1.1
        bezier = winOut, 0.3, -0.3, 0, 1
        bezier = liner, 1, 1, 1, 1
        animation = windows, 1, 6, wind, slide
        animation = windowsIn, 1, 6, winIn, slide
        animation = windowsOut, 1, 5, winOut, slide
        animation = windowsMove, 1, 5, wind, slide
        animation = border, 1, 1, liner
        animation = borderangle, 1, 30, liner, loop
        animation = fade, 1, 10, default
        animation = workspaces, 1, 5, wind
      }

      dwindle {
        pseudotile = yes
        preserve_split = yes
      }

      gestures {
        workspace_swipe = off
      }

      $mainMod = ALT_R

      # Application bindings
      bind = $mainMod, R, exec, rofi -config ~/.config/rofi/bottom_large.rasi -show drun || killall rofi
      bind = $mainMod, N, exec, cliphist list | rofi -dmenu -display-columns 2 | cliphist decode | wl-copy || killall rofi
      bind = $mainMod, T, exec, kitty
      bind = $mainMod, W, exec, firefox
      bind = $mainMod, E, exec, kitty --single-instance --detach zsh -i -c 'yazi'
      bind = $mainMod, D, exec, vesktop
      bind = $mainMod, P, exec, select_wallpaper
      bind = $mainMod, C, exec, hyprctl keyword animation "fadeOut,0,0,default"; grimblast --freeze save area - | satty --filename - --fullscreen --output-filename ~/screenshots/$(date '+%Y%m%d-%H:%M:%S').png; hyprctl keyword animation "fadeOut,1,4,default"
      bind = $mainMod, B, exec, BEMOJI_PICKER_CMD="rofi -dmenu -theme ~/.config/rofi/bemoji.rasi" bemoji || killall rofi

      # Window management bindings
      bind = $mainMod, M, exit,
      bind = $mainMod, Q, killactive,

      bind = $mainMod, F, togglefloating,
      bind = $mainMod, F, resizeactive, exact 1280 720
      bind = $mainMod, F, centerwindow

      bind = $mainMod, O, pseudo,
      bind = $mainMod, S, togglesplit,

      bind = $mainMod SHIFT, h, swapwindow, l
      binde = $mainMod SHIFT, h, moveactive, -50 0
      bind = $mainMod SHIFT, l, swapwindow, r
      binde = $mainMod SHIFT, l, moveactive, 50 0
      bind = $mainMod SHIFT, k, swapwindow, u
      binde = $mainMod SHIFT, k, moveactive, 0 -50
      bind = $mainMod SHIFT, j, swapwindow, d
      binde = $mainMod SHIFT, j, moveactive, 0 50

      # Computer control bindings
      binde = $mainMod, F2, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
      binde = $mainMod, F3, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
      bind = $mainMod, F4, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
      binde = $mainMod, F8, exec, brightnessctl s 10+
      binde = $mainMod, F7, exec, brightnessctl s 10-
      bind = $mainMod, F11, exec, systemctl suspend
      bind = $mainMod, F12, exec, systemctl poweroff

      # Focus and workspace bindings
      bind = $mainMod, h, movefocus, l
      bind = $mainMod, l, movefocus, r
      bind = $mainMod, k, movefocus, u
      bind = $mainMod, j, movefocus, d
      bind = $mainMod, ampersand, workspace, 1
      bind = $mainMod, Eacute, workspace, 2
      bind = $mainMod, quotedbl, workspace, 3
      bind = $mainMod, apostrophe, workspace, 4
      bind = $mainMod, parenleft, workspace, 5
      bind = $mainMod, minus, workspace, 6
      bind = $mainMod, Egrave, workspace, 7
      bind = $mainMod, underscore, workspace, 8
      bind = $mainMod, ccedilla, workspace, 9
      bind = $mainMod, Agrave, workspace, 10

      # Move active window to workspace
      bind = $mainMod SHIFT, ampersand, movetoworkspace, 1
      bind = $mainMod SHIFT, Eacute, movetoworkspace, 2
      bind = $mainMod SHIFT, quotedbl, movetoworkspace, 3
      bind = $mainMod SHIFT, apostrophe, movetoworkspace, 4
      bind = $mainMod SHIFT, parenleft, movetoworkspace, 5
      bind = $mainMod SHIFT, minus, movetoworkspace, 6
      bind = $mainMod SHIFT, Egrave, movetoworkspace, 7
      bind = $mainMod SHIFT, underscore, movetoworkspace, 8
      bind = $mainMod SHIFT, ccedilla, movetoworkspace, 9
      bind = $mainMod SHIFT, Agrave, movetoworkspace, 10

      # Scratchpads
      bind = $mainMod, I, exec, pypr toggle term && hyprctl dispatch bringactivetotop
      $scratchpadsize = size 80% 70%
      $scratchpad = class:^(scratchpad)$
      windowrulev2 = float, $scratchpad
      windowrulev2 = $scratchpadsize, $scratchpad
      #windowrulev2 = center, $scratchpad
      windowrulev2 = workspace special silent, $scratchpad

      # Move/resize windows
      bindm = $mainMod, mouse:272, movewindow
      bindm = $mainMod, mouse:273, resizewindow
      bind = $mainMod, Z, submap, resize
      submap = resize
      binde = ,l,resizeactive,20 0
      binde = ,h,resizeactive,-20 0
      binde = ,k,resizeactive,0 -20
      binde = ,j,resizeactive,0 20
      bind = $mainMod, Z, submap, reset
      submap = reset

      # window rule
      #windowrule = animation slide bottom, kitty
      windowrule = opacity 0.92 override, vesktop
      windowrule = opacity 0.99 override, firefox

      # To make screensharing work
      exec-once=dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP

      exec-once=pypr
      exec-once=startup
    '';
  };
}

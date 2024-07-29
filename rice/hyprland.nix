{pkgs, ...}:
{
  wayland.windowManager.hyprland = {
    # Whether to enable Hyprland wayland compositor
    enable = true;
    # The hyprland package to use
    package = pkgs.hyprland;
    # Whether to enable XWayland
    xwayland.enable = true;

    # Optional
    # Whether to enable hyprland-session.target on hyprland startup
    systemd.enable = true;
    extraConfig = ''
      # NVIDIA env
      env = LIBVA_DRIVER_NAME,nvidia
      env = XDG_SESSION_TYPE,wayland
      env = GBM_BACKEND,nvidia_drm
      env = __GLX_VENDOR_LIBRARY_NAME,nvidia
      env = WLR_NO_HARDWARE_CURSORS,1

      # Electron env for wayland
      env = ELECTRON_OZONE_PLATFORM_HINT,auto

      # env = WLR_DRM_DEVICES,/dev/dri/card0:/dev/dri/card1

      # Monitor settings
      monitor=eDP-1, 1920x1080, 0x0, 1

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
        col.active_border = $color1 $color2 100deg
        col.inactive_border = rgba(595959aa)
        layout = dwindle
      }

      misc {
        disable_hyprland_logo = true
        disable_splash_rendering = true
      }

      decoration {
        rounding = 10
        blur {
          enabled = true
          size = 2
          passes = 1
        }
        drop_shadow = yes
        shadow_range = 4
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

      windowrule = noblur, kando 
      windowrule = size 100% 100%, kando
      windowrule = noborder, kando
      windowrule = noanim, kando
      windowrule = float, kando
      windowrule = pin, kando

      $mainMod = ALT_R

      # Application bindings
      bind = $mainMod, R, exec, rofi -config ~/.config/rofi/config1.rasi -show drun || killall rofi
      bind = $mainMod, N, exec, cliphist list | rofi -config ~/.config/rofi/config1.rasi -dmenu -display-columns 2 | cliphist decode | wl-copy || killall rofi
      bind = $mainMod, T, exec, kitty
      bind = $mainMod, W, exec, firefox
      bind = $mainMod, E, exec, thunar
      bind = $mainMod, D, exec, discord
      bind = $mainMod, P, exec, ~/./scripts/change_wallpaper
      bind = $mainMod, C, exec, hyprctl keyword animation "fadeOut,0,0,default"; grimblast --freeze --notify copysave area; hyprctl keyword animation "fadeOut,1,4,default"

      # Window management bindings
      bind = $mainMod, M, exit, 
      bind = $mainMod, Q, killactive, 
      bind = $mainMod, F, togglefloating, 
      bind = $mainMod, O, pseudo, 
      bind = $mainMod, S, togglesplit, 

      # Computer control bindings 
      bind = $mainMod, F2, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
      bind = $mainMod, F3, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
      bind = $mainMod, F4, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
      bind = $mainMod, F8, exec, brightnessctl s 10+
      bind = $mainMod, F7, exec, brightnessctl s 10-
      bind = $mainMod, F11, exec, systemctl suspend
      bind = $mainMod, F12, exec, poweroff

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

      # Scroll through existing workspaces
      bind = $mainMod, mouse_down, workspace, e+1
      bind = $mainMod, mouse_up, workspace, e-1

      # Move/resize windows
      bindm = $mainMod, mouse:272, movewindow
      bindm = $mainMod, mouse:273, resizewindow
      bind = $mainMod, Z, submap, resize
      submap = resize
      binde = ,l,resizeactive,10 0
      binde = ,h,resizeactive,-10 0
      binde = ,k,resizeactive,0 -10
      binde = ,j,resizeactive,0 10
      bind = $mainMod, Z, submap, reset 
      submap = reset

      # To make screensharing work
      exec-once=dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
      exec-once=~/.config/hypr/scripts/startup
    '';
  };
}

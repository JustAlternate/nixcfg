{
  pkgs,
  ...
}:
{
  xdg.configFile."waybar/style.css".source = ./waybar-style.css;

  programs.waybar = {
    enable = true;
    package = pkgs.waybar;
    settings = [
      {
        layer = "top";
        position = "top";
        modules-center = [
          "clock"
        ];
        modules-left = [
          "hyprland/workspaces"
        ];
        modules-right = [
          "custom/media"
          "tray"
          "pulseaudio"
          "cpu"
          "memory"
          "battery"
          "network"
        ];

        "hyprland/workspaces" = {
          active-only = false;
          show-special = false;
          all-outputs = false;
          disable-scroll = true;
          format = "{icon}";
          format-icons = {
            default = "○";
            active = "";
            urgent = "!";
          };
          persistent-workspaces = {
            "*" = 10;
          };
        };
        "clock" = {
          format = "  {:L%H:%M}";
          tooltip = true;
          tooltip-format = "<big>{:%A, %d.%B %Y }</big>\n<tt><small>{calendar}</small></tt>";
        };
        "custom/media" = {
          exec = "playerctl metadata --format '{{ title }}' 2>/dev/null";
          exec-on-event = true;
          interval = 5;
          format = "{}";
          max-length = 40;
          tooltip = true;
          escape = false;
          on-click = "playerctl play-pause";
        };
        "hyprland/window" = {
          max-length = 22;
          separate-outputs = false;
          rewrite = {
            "" = " 🙈 No Windows? ";
          };
        };
        "memory" = {
          interval = 10;
          format = " {}%";
          tooltip = true;
        };
        "cpu" = {
          interval = 10;
          format = " {usage:2}%";
          tooltip = true;
        };
        "disk" = {
          format = " {free}";
          tooltip = true;
        };
        "network" = {
          format-icons = [
            "󰤯 "
            "󰤟 "
            "󰤢 "
            "󰤥 "
            "󰤨 "
          ];
          format-ethernet = "󰈁";
          format-wifi = "{icon}";
          format-disconnected = "󰤮 ";
          tooltip = false;
        };
        "tray" = {
          spacing = 20;
          icon-size = 16;
          show-passive-items = true;
        };
        "pulseaudio" = {
          format = "{icon} {volume}%";
          format-bluetooth = "{volume}% {icon} ";
          format-bluetooth-muted = "󰝟 {icon} ";
          format-muted = "󰍭 {format_source} ";
          format-source = " {volume}% ";
          format-source-muted = " ";
          format-icons = {
            headphone = " ";
            hands-free = " ";
            headset = " ";
            phone = " ";
            portable = " ";
            car = " ";
            default = [
              ""
              " "
              " "
            ];
          };
          on-click = "sleep 0.1 && pwvucontrol";
        };
        "battery" = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{icon} {capacity}%";
          format-charging = "󰂄 {capacity}%";
          format-plugged = "󱘖 {capacity}%";
          format-icons = [
            "󰁺"
            "󰁻"
            "󰁼"
            "󰁽"
            "󰁾"
            "󰁿"
            "󰂀"
            "󰂁"
            "󰂂"
            "󰁹"
          ];
          on-click = "";
          tooltip = true;
        };
      }
    ];
  };
}

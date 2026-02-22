_: {
  services.dunst = {
    enable = true;

    settings.global = {
      notification_limit = 10;
      gap_size = 10;
      offset = "(25, 25)";

      min_icon_size = 64;
      max_icon_size = 64;
      vertical_alignment = "top";

      font = "Hack Nerd Mono 15";
      line_height = 2;
      padding = 12;
      horizontal_padding = 12;
      text_icon_padding = 12;

      frame_width = 2;
      corner_radius = 10;
      width = "(400, 800)";

      progress_bar_corner_radius = 1;
      progress_bar_height = 8;

      show_indicators = "no";
    };
  };
}

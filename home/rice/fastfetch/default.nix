_: {
  programs.fastfetch = {
    enable = true;
    settings = {
      logo = {
        source = "nixos_small";
        padding = {
          right = 5;
        };
      };

      display = {
        binaryPrefix = "si";
        color = "white";
        separator = "  ";
      };

      modules = [
        {
          "type" = "title";
          "key" = "";
        }
        "break"
        {
          "type" = "custom";
          "format" = "╭──────────────────────SYSTEM──────────────────────╮";
        }
        {
          "type" = "os";
          "key" = "╭─ OS";
        }
        {
          "type" = "uptime";
          "key" = "├─  UPTIME";
        }
        {
          "type" = "packages";
          "key" = "├─  PACKAGES";
        }
        {
          "type" = "wm";
          "key" = "├─  WINDOW MANAGER";
        }
        {
          "type" = "terminal";
          "key" = "╰─  TERMINAL";
        }
        {
          "type" = "custom";
          "format" = "╰────────────────────────────────────────────────╮";
        }
        "break"
      ];
    };
  };
}

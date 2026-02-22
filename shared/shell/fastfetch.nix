{ pkgs, ... }:
{
  programs.fastfetch = {
    package = pkgs.fastfetch;
    enable = true;
    settings = {
      logo = {
        source = "nixos_small";
        padding = {
          right = 1;
          top = 1;
        };
      };

      display = {
        size.binaryPrefix = "si";
        color = "cyan";
        separator = "  ";
      };

      modules = [
        {
          "type" = "custom";
          "format" = "╭──────────────────────SYSTEM──────────────────────╮";
        }
        {
          "type" = "title";
          "key" = "├─ HOST";
          "keyColor" = "blue";
        }
        {
          "type" = "os";
          "key" = "├─ OS";
          "format" = "{3} ({12})";
          "keyColor" = "red";
        }
        {
          "type" = "kernel";
          "key" = "├─ KERNEL";
          "format" = "{1} {2}";
          "keyColor" = "green";
        }
        {
          "type" = "uptime";
          "key" = "├─ UPTIME";
          "keyColor" = "yellow";
        }
        {
          "type" = "packages";
          "key" = "├─ PACKAGES";
          "keyColor" = "blue";
        }
        {
          "type" = "wm";
          "key" = "├─ WINDOW MANAGER";
          "keyColor" = "red";
        }
        {
          "type" = "terminal";
          "key" = "├─ TERMINAL";
          "keyColor" = "green";
        }
        {
          "type" = "media";
          "key" = "├─󰝚 PLAYING";
          "keyColor" = "yellow";
          "format" = "{1}";
        }
        {
          "type" = "custom";
          "format" = "╰──────────────────────────────────────────────────╯";
        }
        "break"
      ];
    };
  };
}
